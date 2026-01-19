<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
	com.oopsclick.silk.utils.SilkPath,
	com.oopsclick.silk.utils.FileTool"
%>
<%

	String systemPath = SilkPath.getRealPath(request);

	String systemUUID = request.getParameter("systemUUID")+"/";
	String sourceTheme = request.getParameter("sourceTheme");
	String targetTheme = request.getParameter("targetTheme");

	systemPath = systemPath + "/silk/theme/"+systemUUID;

	String sourcePath = systemPath + sourceTheme;
	String targetPath = systemPath + targetTheme.trim().replaceAll(" ","_");

	FileTool.copyFolder(sourcePath, targetPath);
	
%>
