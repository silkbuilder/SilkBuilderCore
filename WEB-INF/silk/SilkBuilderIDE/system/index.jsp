<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.oopsclick.silk.dbo.*" %>
<%
	
	String silkSystemID = (String) request.getAttribute("urlParameter0");

	if( silkSystemID==null ){
		out.println("No system defined.");
		return;
	}

	String developerRole = "" ;
	String systemName = "";
	
	DataProvider developerDP = new DataProvider("/../silk/SilkBuilderIDE/silkSystem",session);
	developerDP.setParameter("silkSystemID",silkSystemID);
	developerDP.select("systemLoader");
	developerRole = "admin";
	systemName = developerDP.getStringItem("systemName");
	
	session.setAttribute("silkSystemID", silkSystemID);
	request.setAttribute("developerRole", developerRole);
	session.setAttribute(silkSystemID+"-role", developerRole);
	
%>
<silk:App title="SilkBuilder IDE" >

	<silk:JScode>
		var silkSystemID = "<%= silkSystemID %>";
		var systemName = "<%= systemName %>";
	</silk:JScode>

	<silk:Screen>
		<%@ include file="index/moduleStructure.jsp" %>
		<%@ include file="index/moduleOptions.jsp" %>
		<%@ include file="index/moduleProject.jsp" %>
		<%@ include file="index/moduleEditor.jsp" %>
		<%@ include file="index/moduleTag.jsp" %>
		<%@ include file="index/moduleSync.jsp" %>
	</silk:Screen>

</silk:App>
