<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.oopsclick.silk.dbo.DataProvider" %>
<%
	
	/*
	 * Accessed by other applications
	 */
	
	String silkSystemID = (String) request.getAttribute("urlParameter1");
	if( silkSystemID==null ) return;
	
	DataProvider systemDP = new DataProvider("/../silk/SilkBuilderIDE/silkSystem",session);
	systemDP.setParameter("silkSystemID", silkSystemID);
	systemDP.select("systemLoader");
	
	String silkSystemUUID = systemDP.getStringItem("silkSystemUUID");
	
	String developerRole = (String) session.getAttribute(silkSystemID+"-role");
	request.setAttribute("developerRole",developerRole);
%>
<script>
	var silkSystemID = "<%= silkSystemID %>";
	var silkSystemUUID = "<%= silkSystemUUID %>";
</script>