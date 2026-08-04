<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
		com.oopsclick.silk.dbo.*,
		com.oopsclick.silk.utils.SilkPath,
		com.oopsclick.silk.utils.Tools,
		com.oopsclick.silk.utils.Builder,
		java.io.*,
		org.json.simple.JSONArray,
		org.json.simple.JSONObject,
		org.json.simple.parser.JSONParser,
		org.json.simple.parser.ParseException,
		java.util.ArrayList,
		java.util.List,
		java.util.Scanner,
		java.util.regex.Matcher,
		java.util.regex.Pattern	
	"
%>
<%
	
	String silkProjectID = request.getParameter("silkProjectID");

	// Change this for production.
	String contextPath = request.getServletContext().getRealPath("/");
	String appPath = "";
	String projectPath = "";
	String servicePath = "";
	String sourcePath = "";
		
	appPath = SilkPath.clearEclipsePath(contextPath)+"WEB-INF/workspace/";
	
	/*
	 * Search Project in database
	 */
	DataProvider sourceDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject");
	sourceDP.setParameter("silkProjectID", silkProjectID);
	int total = sourceDP.select("sourceData");
	
	if( total==0 ) return;
	
	String silkSystemID	= sourceDP.getStringItem(0, "silkSystemID");
	String resourceUUID	= sourceDP.getStringItem(0, "resourceUUID");
	String projectUUID	= sourceDP.getStringItem(0, "projectUUID");
	String projectID	= sourceDP.getStringItem(0, "projectID");
	String sourceName	= sourceDP.getStringItem(0, "sourceName");
	String parentName	= sourceDP.getStringItem(0, "parentName");
	String moduleParent	= sourceDP.getStringItem(0, "moduleParent");
	String content		= sourceDP.getStringItem(0, "content");
	int saveMode		= sourceDP.getIntItem(0, "saveMode");
	String extension	= sourceDP.getStringItem(0, "extension");
	String nodeType		= sourceDP.getStringItem(0, "nodeType");

	if( saveMode==0 ) return;
	
	/*
	 * ProjectPath
	 */
	projectPath = appPath+projectUUID;

	/*
	 * Service Path
	 */
	servicePath = projectPath + "/"+parentName;
	
	/*
	 * Source Path
	 */
	if( saveMode>1 ){
		if( nodeType.equals("MOD") ){
			/*
			 * Adds module parent to source path
			 */
			sourcePath = servicePath + "/" + moduleParent + "/"+sourceName+extension;
		}else{
			sourcePath = servicePath + "/"+sourceName+extension;
		}
	}else{
		sourcePath = projectPath + "/"+sourceName+extension;
	}	
	
	//System.out.println( sourcePath );
	
	/*
	 * Creates project folder if it does not exist
	 */
	File projectFolder = new File(projectPath);
	if( !projectFolder.exists() ) { 
		projectFolder.mkdir();
	}
	
	/*
	 * Creates service folder if it does not exist and saveMode is more than 1
	 */
	File serviceFolder = new File(servicePath);
	if( saveMode>1 ){
		if( !serviceFolder.exists() ) { 
			serviceFolder.mkdir();
		}
	}
	
	/*
	 * Creates module parent folder
	 */
	if( nodeType.equals("MOD") ){
		File moduleFolder = new File(servicePath+"/"+moduleParent);
		if( saveMode>1 ){
			if( !moduleFolder.exists() ) { 
				moduleFolder.mkdir();
			}
		}	
	}
	
	/*
	 * Creates source file if it does not exist.
	 */
	File sourcefile = new File(sourcePath);
	if (!sourcefile.exists()) {
		sourcefile.createNewFile();
	}
	
	/*
	 * Process ORM and Outlets private and public.
	 */
	if( nodeType.equals("ORM") || nodeType.equals("ORMF") ) content = Builder.ormToXml(content, nodeType);

	/*
	 * Process Outlets
	 */
	if( nodeType.equals("OSL") || nodeType.equals("OSLP") ) content = Builder.outletToJsp(content);

	/*
	 * Process mail templates
	 */
	if( nodeType.equals("EMAIL") ){
		Builder.emailToDatabase(content, silkSystemID, session);
		return;
	}

	//System.out.println(sourceFile);
	//System.out.println(content);
	
	/*
	 * Writes content into source file.
	 */
	FileWriter fileWriter = new FileWriter(sourcefile,false);
	fileWriter.write(content);
	fileWriter.close();

	
%>