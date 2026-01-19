<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
		com.oopsclick.silk.dbo.*,
		com.oopsclick.silk.utils.SilkPath,
		com.oopsclick.silk.utils.FileTool
	"
%>
<%

	String silkProjectID = request.getParameter("silkProjectID");
	String previousName = request.getParameter("previousName");

	String contextPath = request.getServletContext().getRealPath("/");
	String appPath = SilkPath.clearEclipsePath(contextPath)+"WEB-INF/workspace/";
	String projectPath = "";
	String servicePath = "";
	String sourcePath = "";
	String previousPath = "";
	
	/*
	 * Search Project in database
	 */
	DataProvider sourceDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject");
	sourceDP.setParameter("silkProjectID", silkProjectID);
	int total = sourceDP.select("sourceData");

	if( total==0 ) return;

	String projectUUID	= sourceDP.getStringItem("projectUUID");
	String sourceName	= sourceDP.getStringItem("sourceName");
	String parentName	= sourceDP.getStringItem("parentName");
	String moduleParent	= sourceDP.getStringItem("moduleParent");
	//String content		= sourceDP.getStringItem("content");
	int saveMode		= sourceDP.getIntItem("saveMode");
	String extension	= sourceDP.getStringItem("extension");
	String nodeType		= sourceDP.getStringItem("nodeType");
	
	/*
	 * ProjectPath
	 */
	projectPath = appPath+projectUUID;

	if( nodeType.equals("SRV") ){
		/*
		 * Rename Service Pool folder
		 */

		/*
		 * Service Path
		 */
		previousPath = projectPath + "/" + previousName;
		sourcePath = projectPath + "/" + parentName;
		
	}else{
		/*
		 * Rename Service Resource
		 */

		/*
		 * Service Path
		 */
		servicePath = projectPath + "/" + parentName;
		
		/*
		 * Source Path
		 */
		if( saveMode>1 ){
			if( nodeType.equals("MOD") ){
				/*
				 * Adds module parent to source path
				 */
				previousPath = servicePath + "/" + moduleParent + "/"+previousName+extension;
				sourcePath = servicePath + "/" + moduleParent + "/"+sourceName+extension;
			}else{
				previousPath = servicePath + "/"+previousName+extension;
				sourcePath = servicePath + "/"+sourceName+extension;
			}
				
		}else{
			previousPath = projectPath + "/"+previousName+extension;
			sourcePath = projectPath + "/"+sourceName+extension;
		}
	}

	/*
	 * Rename process
	 */
	FileTool.renameFile("", previousPath, sourcePath);

	if( nodeType.equals("APP") || nodeType.equals("PUB") ){
		/*
		 * If appllication, renames application folder if exists.
		 */
		previousPath = servicePath + "/"+previousName;
		sourcePath = servicePath + "/"+sourceName;
		FileTool.renameFile("", previousPath, sourcePath);		
	}
	
	//System.out.println("================");
	//System.out.println(previousPath);
	//System.out.println(sourcePath);
	
%>{"status":"done"}