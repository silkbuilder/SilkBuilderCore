<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
	com.oopsclick.silk.dbo.*,
	com.oopsclick.silk.utils.FileTool,
	com.oopsclick.silk.utils.Tool64,
	com.oopsclick.silk.utils.SilkPath,
	com.oopsclick.silk.utils.ServiceConnection,
	java.io.*,
	java.util.*,
	java.net.*,
	java.util.HashMap,
	javax.net.ssl.HttpsURLConnection,
	org.json.simple.JSONArray,
	org.json.simple.JSONObject"
%>
<%
	
	response.setContentType("application/json");

	/*
	 * Initialize JSON object
	 */
	JSONObject data = new JSONObject();
	
	/*
	 * Loading silkSystemID parameter
	 */
	String silkSystemID = request.getParameter("silkSystemID");
	String silkSystemUUID = "";
		
	/*
	 * Loading silkProjectUUID parameter
	 */
	String silkProjectID = request.getParameter("silkProjectID");
	if( silkProjectID==null ) silkProjectID="";
	
	/* ----------------------------------------------------------
	 * Loading targetHost parameter
	 */
	String silkTargetID = request.getParameter("silkTargetID");
	String silkTargetURL = "";
	String accessToken = "";
	String db = "";
	String db1 = "";
	String db2 = "";
	String db3 = "";
	String db4 = "";
	
	DataProvider targetDP = new DataProvider("/../silk/SilkBuilderIDE/silkTarget", session);
	targetDP.setParameter("silkTargetID",silkTargetID);
	if( targetDP.select("targetURL")==0 ){
		out.println("{\"result\":0, \"code\":0, \"message\":\"No Target Host\"}");
		System.out.println("{\"result\":0, \"code\":0, \"message\":\"No Target Host\"}");
		return;
	}
	
	silkSystemUUID = targetDP.getStringItem("silkSystemUUID");
	silkTargetURL = targetDP.getStringItem("targetURL");
	accessToken = targetDP.getStringItem("accessToken");
	db = targetDP.getStringItem("targetdb");
	db1 = targetDP.getStringItem("targetdb1");
	db2 = targetDP.getStringItem("targetdb2");
	db3 = targetDP.getStringItem("targetdb3");
	db4 = targetDP.getStringItem("targetdb4");
	
	if( accessToken.equals("") ){
		out.println("{\"result\":0, \"code\":1, \"message\":\"No Token Configured\"}");
		return;
	}
	
	/*
	 * Clean project request
	 */
	String cleanProject = request.getParameter("cleanProject");
	
	/*
	 * Set contextPath
	 */
	String systemPath = SilkPath.getRealPath(request.getServletContext());
	String workspacePath = systemPath + "WEB-INF/workspace";
	
	//System.out.println( workspacePath );
	//System.out.println(silkProjectID);
	//System.out.println(silkTargetURL);
	//System.out.println(cleanProject);

	/*
	 * Project Records
	 */
	JSONArray containerList = new JSONArray();
	String trackContainerID = "";

	/*
	 * Clean Project
	 */
	JSONArray cleanList = new JSONArray();
	String cleanID = "";
	String cleanUUID = "";

	/*
	 * ==========================================================
	 * System extraction
	 * ----------------------------------------------------------
	 */
	JSONObject systemItem = new JSONObject();
	if( silkProjectID.equals("0") ){
		DataProvider systemDP = new DataProvider("/../silk/SilkBuilderIDE/silkSystem", session);
		systemDP.setParameter("silkTargetID", silkTargetID);
		systemDP.select("sync-system");
		systemItem.put("silkSystemUUID", silkSystemUUID);
		systemItem.put("systemName", systemDP.getStringItem("systemName"));
		systemItem.put("theme", systemDP.getStringItem("theme"));
		systemItem.put("langID", systemDP.getStringItem("langID"));
		systemItem.put("menuLink", systemDP.getStringItem("menuLink"));
		systemItem.put("loginLink", systemDP.getStringItem("loginLink"));
		
		/*
		 * Requests a cleaning of tags.
		 */
		systemItem.put("clean", true);
		
	}else{
		/*
		 * No cleaning, just sync.
		 */
		systemItem.put("clean", false);
		
	}
	data.put("system", systemItem);

	/* ----------------------------------------------------------
	 * Theme extraction
	 */
	if( silkProjectID.equals("0") ){
		String rootPath = systemPath+"silk/theme/"+silkSystemUUID;
		List<String> filePaths = FileTool.getFilesRecursively(rootPath);
		int pos = rootPath.length()+1;

		JSONArray themeList = new JSONArray();
		for (String filePath : filePaths) {
			
			String finalPath = filePath.substring(pos);
			String fileContent = FileTool.readFile(filePath);
			
			JSONObject themeItem = new JSONObject();
			themeItem.put("path",finalPath);
			themeItem.put("content",fileContent);
	        themeList.add(themeItem);
	    }
		data.put("themeList", themeList);
	}
	
	/* ----------------------------------------------------------
	 * File code extraction
	 */
	DataProvider historyDP = new DataProvider("/../silk/SilkBuilderIDE/silkCodeHistory", session);
	DataProvider codeDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject", session);
	codeDP.setParameter("silkProjectID", silkProjectID);
	codeDP.select("sync-files");
	JSONArray codeList = new JSONArray();
	for(int x=0; x<codeDP.size(); x++){
		
		/*
		 * Get project resources
		 */
		String syncSilkProjectID = codeDP.getStringItem(x,"syncSilkProjectID");
		String filePath = codeDP.getStringItem(x,"filePath");
		String fileName = codeDP.getStringItem(x,"fileName");
		String nodeType = codeDP.getStringItem(x,"nodeType");

		/*
		 * Get file content
		 */
		String fileContent = FileTool.readFile(workspacePath+filePath+fileName);

		/*
		 * Replace db variables in ORMs
		 */
		if( nodeType.equals("ORM") || nodeType.equals("ORMF") ){
			if( fileContent.contains("{db}") ) fileContent = fileContent.replaceAll("\\{db\\}", db);
			if( fileContent.contains("{db1}") ) fileContent = fileContent.replaceAll("\\{db1\\}", db1);
			if( fileContent.contains("{db2}") ) fileContent = fileContent.replaceAll("\\{db2\\}", db2);
			if( fileContent.contains("{db3}") ) fileContent = fileContent.replaceAll("\\{db3\\}", db3);
			if( fileContent.contains("{db4}") ) fileContent = fileContent.replaceAll("\\{db4\\}", db4);
		}

		if( nodeType.equals("ORM")  ){
			String[] codeLines = fileContent.split("\n");
			fileContent = "";
			for( String line : codeLines){
				if( line.contains("silkSystemID") ) continue;
				fileContent += line+"\n";
			}
		}
		
		/*
		 * Filling code array
		 */
		JSONObject codeItem = new JSONObject();
		codeItem.put("filePath",filePath);
		codeItem.put("fileName",fileName);
		codeItem.put("fileContent",fileContent);
		codeList.add(codeItem);

		/*
		 * Container List
		 */
		int isResource = codeDP.getIntItem(x,"isResource");
		if( isResource==1 ){
			String containerID = codeDP.getStringItem(x,"containerID");
			if( !trackContainerID.equals(containerID) ){
				trackContainerID = containerID;
				JSONObject containerItem = new JSONObject();
				containerItem.put("containerID", containerID);
				containerItem.put("containerName", codeDP.getStringItem(x,"containerName"));
				containerItem.put("clean", cleanProject );
				containerList.add(containerItem);
			}
		}

		/*
		 * Set as commit
		 */
		historyDP.setParameter("silkProjectID", syncSilkProjectID);
		if( historyDP.select("lastID")>0 ){
			String silkCodeHistoryID = historyDP.getItem("silkCodeHistoryID");
			historyDP.setParameter("silkCodeHistoryID", silkCodeHistoryID);
			historyDP.exec("commitCode");
		}
		
	}
	data.put("containerList", containerList);
	data.put("codeList", codeList);

	/* ----------------------------------------------------------
	 * Email template extraction
	 * Checks if it is a pro version
	 */
	File file = new File(systemPath+"WEB-INF/silk/SilkBuilderIDE/silkDeveloper.orm");
	if( file.exists() ){
		DataProvider emailDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject", session);
		emailDP.setParameter("silkProjectID", silkProjectID);
		emailDP.select("sync-email");
		JSONArray emailList = new JSONArray();
		for(int x=0; x<emailDP.size(); x++){
			JSONObject emailItem = new JSONObject();
			emailItem.put("emailUUID", emailDP.getStringItem(x,"emailUUID"));
			emailItem.put("langID", emailDP.getStringItem(x,"langID"));
			emailItem.put("wrapper", emailDP.getStringItem(x,"wrapper"));
			emailItem.put("sentFrom", emailDP.getStringItem(x,"sentFrom"));
			emailItem.put("replyTo", emailDP.getStringItem(x,"replyTo"));
			emailItem.put("copyTo", emailDP.getStringItem(x,"copyTo"));
			emailItem.put("blindTo", emailDP.getStringItem(x,"blindTo"));
			emailItem.put("subject", emailDP.getStringItem(x,"subject"));
			emailItem.put("message", emailDP.getStringItem(x,"message"));
			emailItem.put("indexValue", emailDP.getStringItem(x,"indexValue"));
			emailList.add(emailItem);
		}
		data.put("emailList", emailList);
	}
		
	/* ----------------------------------------------------------
	 * Tag extraction
	 */
	DataProvider tagDP = new DataProvider("/../silk/SilkBuilderIDE/silkTag", session);
	String selectName = "sync-tags";
		
	if( silkProjectID.equals("0") ){
		/*
		 * Requests a full sync of tags.
		 */
		selectName = "sync-full-tags";
	}else{
		tagDP.setParameter("silkTargetID", silkTargetID);
	}
		
	tagDP.select(selectName);
	JSONArray tagList = new JSONArray();
	for(int x=0; x<tagDP.size(); x++){
		JSONObject tagItem = new JSONObject();
		tagItem.put("groupName", tagDP.getStringItem(x,"groupName"));
		tagItem.put("tagName", tagDP.getStringItem(x,"tagName"));
		tagItem.put("tagType", tagDP.getIntItem(x,"tagType"));
		tagItem.put("tagIntValue", tagDP.getIntItem(x,"tagIntValue"));
		tagItem.put("content", tagDP.getStringItem(x,"content"));
		tagItem.put("position", tagDP.getIntItem(x,"position"));
		tagList.add(tagItem);
	}
	data.put("tagList", tagList);
	
	/* ----------------------------------------------------------
	 * Language extraction
	 */
	DataProvider langDP = new DataProvider("/../silk/SilkBuilderIDE/silkLang", session);
	langDP.setParameter("silkTargetID", silkTargetID);
	langDP.select("sync-lang");
	JSONArray langList = new JSONArray();
	for(int x=0; x<langDP.size(); x++){
		JSONObject langItem = new JSONObject();
		langItem.put("langID", langDP.getStringItem(x,"langID"));
		langItem.put("langName", langDP.getStringItem(x,"langName"));
		langItem.put("enName", langDP.getStringItem(x,"enName"));
		langList.add(langItem);
	}
	data.put("langList", langList);
		
	/* ===========================================================
	 * This is use for debuging the loaded sync data without sending data to external service.
	 */
	if( false ){
		System.out.println(data.toString());
		out.println("{\"result\":1, \"code\":1, \"message\":\"Debug Process Only.\"}");
		return;
	}
	
	/* 
	 * ===========================================================
	 * Generate service URL and initialize the Service Connection.
	 * -----------------------------------------------------------
	 */
	String silkServiceURL = SilkPath.cleanURL(silkTargetURL+"/auth/syncCode");
	ServiceConnection sc = new ServiceConnection(silkServiceURL, accessToken);

	//System.out.println( silkTargetURL );
	//System.out.println( accessToken );

	/*
	 * Load code into the service body.
	 */
	sc.setBody( Tool64.stringToBase64(data.toString()) );
		
	/*
	 * Loading service
	 */
	int result = 1;
	int responseCode = 200;
	String responseMessage = "Sucess";
		
	if( sc.loadJSON() ){
		result = sc.getJsonQuery().getInt("$.result");
		responseCode = sc.getJsonQuery().getInt("$.code");
		responseMessage = sc.getJsonQuery().get("$.message");

		/*
		 * Updates target sync date if sync is correct.
		 */
		if( result==1 )	targetDP.exec("updateSyncDate");
		
	}else{
		result = 0;
		responseCode = sc.getResponseCode();
		responseMessage = sc.getResponseCodePhrase();
	}
		
%>
{
	"result" : <%= result %>,
	"code" : <%= responseCode %>,
	"message" : "<%= responseMessage %>"
}
