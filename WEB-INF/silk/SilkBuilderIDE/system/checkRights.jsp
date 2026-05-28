<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
	com.oopsclick.silk.dbo.*,
	com.oopsclick.silk.utils.SilkPath,
	java.io.*"
%>
<%

	/*
	 * Gets the project's ID
	 */
	String silkProjectID = (String) request.getAttribute("urlParameter0");
	if( silkProjectID==null ){
		return;
	}
	
	/*
	 * Gets the system's ID
	 */
	String silkSystemID = (String) request.getAttribute("urlParameter1");
	if( silkSystemID==null ){
		return;
	}
	
	/*
	 * Gets the loaded developer role
	 */
	String developerRole = (String) session.getAttribute(silkSystemID+"-role");
	/*
	 * developer, architect, read, admin
	 */

	/*
	 * Sets the status of the editRight
	 */
	String writeRoles = request.getParameter("writeRoles");
	String editRight = "false";
	if( writeRoles.indexOf(developerRole)>-1 ) editRight = "true";
	request.setAttribute("editRight",editRight);

	/*
	 * Check if it is core.
	 */
	String systemPath = SilkPath.getRealPath(request.getServletContext());
	File file = new File(systemPath+"WEB-INF/silk/SilkBuilderIDE/silkDeveloper.orm");
	if( file.exists() ){
		request.setAttribute("isPro",1);
	}else{
		request.setAttribute("isPro",0);
	}
	
	/*
	 * Load the list of the system's database
	 */
	DataProvider databaseDP = new DataProvider("/../silk/SilkBuilderIDE/silkDatabase",session);	
	databaseDP.setParameter("silkSystemID",silkSystemID);
	int total = databaseDP.select("targetDatabaseList");

	String databaseList = "";
	for( int x=0; x<total; x++ ){
		databaseList +=  databaseDP.getStringItem(x,"silkDatabaseID")+"|"+databaseDP.getStringItem(x,"databaseName")+"," ;
	}
	request.setAttribute("databaseList",databaseList);
	
%>