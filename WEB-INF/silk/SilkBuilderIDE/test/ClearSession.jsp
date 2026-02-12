<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page
	import="
		java.util.Enumeration,
		com.oopsclick.silk.security.Crypt
	"
%>
<%
	
	Crypt crypt = new Crypt();
	
	String action = request.getParameter("action");
	if( action == null ) action = "0";

	String attributeList = "";

	if( action.equals("1") ) session.setAttribute("silkRoleList","");

	Enumeration<String> attributes = session.getAttributeNames();
	while (attributes.hasMoreElements()) {
		String attribute = attributes.nextElement();

		/*
		 * Ignore the following variables
		 */
		if( attribute.equals("template") ) continue; 
		if( attribute.equals("devSession") ) continue;
		if( attribute.equals("^silkDevID") ) continue;
		if( attribute.equals("^silkDevName") ) continue;
		if( attribute.equals("^silkUserName") ) continue;
		if( attribute.equals("^silkAdmin") ) continue;
		if( attribute.equals("devRoleList") ) continue;
		if( attribute.equals("contextPath") ) continue;
		if( attribute.equals("_requestURL") ) continue;
		if( attribute.equals("silkSystemUUID") ) continue;
		if( attribute.equals("silkSystemID") ) continue;
		if( attribute.equals("silkSessionToken") ) continue;
		if( attribute.equals("silkTarget") ) continue;
		if( attribute.equals("silkIdleMinutes") ) continue;
		//if( attribute.equals("langID") ) continue;
		if( attribute.equals("codeCounter") ) continue;
		if( attribute.indexOf("-role")>-1 ) continue;
		
		if( action.equals("2") && !attribute.equals("silkRoleList") ){
			session.removeAttribute( attribute );
		}else{
			String value = (String) session.getAttribute(attribute);
			value = crypt.fixedDecryptValue(value);
			attributeList += "{\"attribute\":\""+attribute+"\", \"value\":\""+value+"\"},";
		}
	}
	
	if( !attributeList.equals("") ) attributeList = attributeList.substring(0, attributeList.length()-1);
	
%>
[<%= attributeList %>]
