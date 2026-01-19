<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
	com.oopsclick.silk.utils.SilkPath,
	com.oopsclick.silk.utils.Form"
%>
<%
	
	/*
	 * Load the request into the an Uloaded object.
	 */
	Form form = new Form(request);
	
	/*
	 * Generate folder path
	 */
	String silkSystemUUID = form.getValue("silkSystemUUID");
	String themeName = form.getValue("themeName");
	String systemPath = SilkPath.getRealPath(request);
	systemPath += "/silk/theme/"+silkSystemUUID+"/"+themeName+"/";

	systemPath = SilkPath.cleanRealPath(systemPath);

	/*
	 * Saves the file in the provided folder.
	 */
	form.saveFile("bootstrapFile", "bootstrap.min.css", systemPath);
	
%>
