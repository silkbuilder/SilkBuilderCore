<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
		com.oopsclick.silk.dbo.DataProvider,
		com.oopsclick.silk.utils.Http,
		com.oopsclick.silk.totp.*
	"
%><%
	
	int action = 1;
	String token = request.getParameter("token");
	if( token==null ) action = 0;

	//System.out.println(token);
	
	String qr64 = "";
	String secretKey = "";
	
	DataProvider developerDP = new DataProvider("/../silk/SilkBuilderIDE/silkDeveloper", session);
	
	//System.out.println("= = = = = = MFA = = = = = = = =");
	//System.out.println("Token "+token);
	//System.out.println("Action "+action);
	
	if( action==0 ){
		developerDP.select("developerProfile");
		TOTPGenerator totp = new TOTPGenerator("SilkBuilder", developerDP.getStringItem("emailAddress") );
		qr64 = totp.getQRCode64Image();
		secretKey = totp.getSecretKey();
		session.setAttribute("totpSecretKey",secretKey);
		//System.out.println("Set "+secretKey);
	}
	
	if( action==1 ){
		secretKey = (String) session.getAttribute("totpSecretKey");
		//System.out.println("Get "+secretKey);
		TOTPValidator totp = new TOTPValidator(secretKey);
		if( totp.isValid(token) ){
			session.removeAttribute("totpSecretKey");
			developerDP.setParameter("secretKey", secretKey);
			developerDP.exec("setTotp");
			action = 1;

			/*
			 * Clean cookie
			 */
			Http.setCookie("access-role","remove", request, response, 0);
		
		}else{
			action = 3;
		}
	}
	
%>
{
	"qr64" : "data:image/png;base64, <%= qr64 %>",
	"action" : <%= action %>
}