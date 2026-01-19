<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page
	import="
		com.oopsclick.silk.dbo.DataProvider,
		com.oopsclick.silk.utils.FileTool,
		com.oopsclick.silk.utils.SilkPath,
		java.util.*
	"
%>
<%

	String silkDevID = (String) request.getAttribute("silkDevID");
	if( silkDevID==null) silkDevID = "0";
	
	if( !silkDevID.equals("0") ){
		/*
		 * Check if user is Admin
		 */
		DataProvider profileDP = new DataProvider("/../silk/SilkBuilderIDE/silkDeveloper",session);
		profileDP.select("developerProfile");
		int silkRoleID = profileDP.getIntItem("silkRoleID");
		if( silkRoleID!=5) return;
	}

	/*
	 * Read Parameter
	 */
	String systemName = request.getParameter("systemName");
	if( systemName==null ) return;

	/*
	 * Read Parameter
	 */
	String silkDatabaseID = request.getParameter("silkDatabaseID");
	if( silkDatabaseID==null ) return;
	
	/*
	 * Generate system UUID
	 */
	UUID uuid = UUID.randomUUID();

	/*
	 * Add system to the database
	 */
	DataProvider systemDP = new DataProvider("/../silk/SilkBuilderIDE/silkSystem",session);
	systemDP.setOperationItem("systemName", systemName);
	systemDP.setOperationItem("silkSystemUUID", uuid.toString());
	systemDP.setOperationItem("databaseList", ","+silkDatabaseID+",");
	systemDP.setOperationItem("silkDatabaseID", silkDatabaseID);
	systemDP.insert();

	/*
	 * Get application path
	 */
	String systemPath = request.getServletContext().getRealPath("/");
	systemPath = SilkPath.clearEclipsePath(systemPath);

	/*
	 * Copy defaul theme to system theme
	 */
	FileTool.copyFolder(systemPath+"silk/theme/default",systemPath+"/silk/theme/"+uuid.toString());

	/*
	 * Get context path
	 */
	String contextPath = (String) request.getAttribute("contextPath");

	/*
	 * Redirect to system editor
	 */
	response.sendRedirect(contextPath+"/service/SilkBuilderIDE/system/index/"+systemDP.getStringItem("silkSystemID"));
	
%>