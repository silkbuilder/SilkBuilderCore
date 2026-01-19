<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
		com.oopsclick.silk.dbo.DataProvider,
		com.oopsclick.silk.utils.FileTool,
		com.oopsclick.silk.utils.Tool64,
		com.oopsclick.silk.utils.SilkPath,
		org.json.simple.JSONArray,
		org.json.simple.JSONObject,
		java.util.List
	"
	trimDirectiveWhitespaces="true"
%>
<%@page contentType="text/plain;charset=UTF-8"%>
<%
	
	String silkSystemID = (String) request.getAttribute("urlParameter0");
	String silkSystemUUID = "";
	String systemName = "";
	String jsonString = "";

	if( silkSystemID==null ) return;
	
	/*
	 * Initialize JSON object
	 */
	JSONObject data = new JSONObject();
	
	/*
	 * Set contextPath
	 */
	String systemPath = SilkPath.getRealPath(request.getServletContext());
	String workspacePath = systemPath + "WEB-INF/workspace";
	
	/* ----------------------------------------------------------
	 * System Export
	 */
	DataProvider systemDP = new DataProvider("/../silk/SilkBuilderIDE/silkSystem", session);
	systemDP.setParameter("silkSystemID", silkSystemID);
	systemDP.select("systemExport");
	silkSystemUUID = systemDP.getStringItem("silkSystemUUID");
	systemName = systemDP.getStringItem("systemName");
	data.put("system", systemDP.getResponseObject().getJSONArray());

	response.setHeader("Content-Disposition", "attachment; filename=\"" + systemName + ".sysilk\"");

	/* ----------------------------------------------------------
	 * Project Export
	 */
	DataProvider projectDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject", session);
	projectDP.setParameter("silkSystemID", silkSystemID);
	projectDP.select("systemExport");
	data.put("project", projectDP.getResponseObject().getJSONArray());

	/* ----------------------------------------------------------
	 * Tag Export
	 */
	DataProvider tagDP = new DataProvider("/../silk/SilkBuilderIDE/silkTag", session);
	tagDP.setParameter("silkSystemID", silkSystemID);
	tagDP.select("tagSystemExport");
	data.put("tag", tagDP.getResponseObject().getJSONArray());

	/* ----------------------------------------------------------
	 * Theme extraction
	 */
	String rootPath = systemPath+"silk/theme/"+silkSystemUUID;
	List<String> filePaths = FileTool.getFilesRecursively(rootPath);
	int pos = rootPath.length()+1;

	JSONArray theme = new JSONArray();
	for (String filePath : filePaths) {
		
		String finalPath = filePath.substring(pos);
		String fileContent = FileTool.readFile(filePath);
		
		JSONObject themeItem = new JSONObject();
		themeItem.put("path",finalPath);
		themeItem.put("content",fileContent);
		theme.add(themeItem);
	}
	data.put("theme", theme);
	
%><%= Tool64.stringToMimeBase64(data.toString()) %>