<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
		com.oopsclick.silk.dbo.DataProvider,
		com.oopsclick.silk.utils.SilkPath,
		com.oopsclick.silk.utils.FileTool,
		java.io.File
	"
%>
<%
	
	String silkSystemID = (String) request.getAttribute("urlParameter0");
	String silkSystemUUID = "";

	if( silkSystemID==null ) return;

	/* ----------------------------------------------------------
	 * Set contextPath
	 */
	String contextPath = SilkPath.getContextPath(request);
	String systemPath = SilkPath.getRealPath(request.getServletContext());
	String themePath = systemPath + "silk/theme";
	String workspacePath = systemPath + "WEB-INF/workspace";
	String ormPath = systemPath + "WEB-INF/silk/SilkBuilderIDE/";
	File file = null;
	
	/* ----------------------------------------------------------
	 * System Information
	 */
	DataProvider systemDP = new DataProvider("/../silk/SilkBuilderIDE/silkSystem", session);
	systemDP.setParameter("silkSystemID", silkSystemID);
	systemDP.select("systemExport");
	silkSystemUUID = systemDP.getStringItem("silkSystemUUID");

	/* ----------------------------------------------------------
	 * Theme folder
	 */
	FileTool.deleteFolder(themePath+"/"+silkSystemUUID);

	/* ----------------------------------------------------------
	 * Project folder
	 */
	DataProvider projectDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject", session);
	projectDP.setParameter("silkSystemID", silkSystemID);
	projectDP.select("projectRemove");

	for( int x=0; x<projectDP.size(); x++ ){
		FileTool.deleteFolder(workspacePath+"/"+projectDP.getStringItem(x,"projectUUID"));
	}

	/* ----------------------------------------------------------
	 * Tags
	 */
	systemDP.exec("removeTags");

	/* ----------------------------------------------------------
	 * System Target
	 */
	systemDP.exec("removeSystemTarget");

	/* ----------------------------------------------------------
	 * Testing
	 */
	systemDP.exec("removeTesting");

	/* ----------------------------------------------------------
	 * System Target
	 */
	systemDP.exec("removeProject");
	
	/*
	 * Check if it is the Pro version
	 */
	file = new File(ormPath+"silkDeveloper.orm");
	if( file.exists() ){

		/* ----------------------------------------------------------
		 * Translators
		 */
		systemDP.exec("removeTranslatorTask");

		/* ----------------------------------------------------------
		 * Developer System
		 */
		systemDP.exec("removeDeveloperSystem");

		/* ----------------------------------------------------------
		 * Email
		 */
		systemDP.exec("removeEmails");
	}

	/* ----------------------------------------------------------
	 * System Target
	 */
	systemDP.exec("removeSystem");
		
	/* ----------------------------------------------------------
	 * System Target
	 */
	response.sendRedirect( contextPath );
	
%>
I am here!!