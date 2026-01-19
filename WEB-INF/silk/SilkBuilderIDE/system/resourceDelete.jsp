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
	String childrenString = request.getParameter("childrenList");
	
	if( childrenString==null ) childrenString = "";
	String[] childrenList = childrenString.split(",");
	
	String contextPath = request.getServletContext().getRealPath("/");
	String appPath = SilkPath.clearEclipsePath(contextPath)+"WEB-INF/workspace/";
	String projectPath = "";
	String servicePath = "";
	String sourcePath = "";
	
	/*
	 * Search Project in database
	 */
	DataProvider sourceDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject",session);
	sourceDP.setParameter("silkProjectID", silkProjectID);
	int total = sourceDP.select("sourceData");

	if( total==0 ) return;

	String projectUUID	= sourceDP.getStringItem("projectUUID");
	String sourceName	= sourceDP.getStringItem("sourceName");
	String parentName	= sourceDP.getStringItem("parentName");
	String moduleParent	= sourceDP.getStringItem("moduleParent");
	String content		= sourceDP.getStringItem("content");
	int projectLevel	= sourceDP.getIntItem("projectLevel");
	int saveMode		= sourceDP.getIntItem("saveMode");
	String extension	= sourceDP.getStringItem("extension");
	String nodeType		= sourceDP.getStringItem("nodeType");

	/*
	 * ProjectPath
	 */
	projectPath = appPath+projectUUID;

	if( nodeType.equals("PRJ") ){
		/*
		 * Removing Project folder
		 */
		FileTool.deleteFolder(projectPath);
	
	}else if( nodeType.equals("DMF") ){
		/*
		 * Removing Data Model files
		 */
		FileTool.deleteFilesIndexOf(projectPath, ".orm");
	
	}else if( nodeType.equals("SRV") ){
		/*
		 * Removing Service Pool folder
		 */
		servicePath = projectPath + "/" + sourceName;
		FileTool.deleteFolder(servicePath);
		
	}else if( projectLevel>2 ){
		if( saveMode>1 ){
			
			if( nodeType.equals("MOD") ){
				/*
				 * Adds module parent to source path
				 */
				sourcePath = projectPath+"/" + parentName + "/" + moduleParent + "/"+sourceName+extension;
			}else{
				sourcePath = projectPath+"/" + parentName + "/"+sourceName+extension;
			}

			/*
			 * Removing savable files
			 */			
			FileTool.deleteFile(sourcePath);

			if( nodeType.equals("APP") || nodeType.equals("PUB") ){
				/*
				 * Removing an application folder
				 */
				sourcePath = projectPath+"/" + parentName + "/"+sourceName;
				FileTool.deleteFolder(sourcePath);
			}
			
		}
		
	}

	/*
	 * Mark children nodes as deleted.
	 */
	if( !childrenString.isEmpty() ){
		sourceDP.cleanOperation();
		for( int x=0; x<childrenList.length; x++ ){
			sourceDP.setOperationAction(x, "update");
			sourceDP.setOperationItem(x, "status",1);
			sourceDP.setOperationItem(x, "silkProjectID", childrenList[x]);
		}
		sourceDP.batch();
	}
	
%>
