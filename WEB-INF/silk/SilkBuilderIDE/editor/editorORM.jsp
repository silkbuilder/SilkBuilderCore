<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@ page import="com.oopsclick.silk.dbo.*,java.io.*" %>
<%@ page contentType="text/html;charset=UTF-8"%>

<jsp:include page="../system/checkRights.jsp" flush="true" >
	<jsp:param name="writeRoles" value="admin,architect" />
</jsp:include>

<%
	String nodeType = (String) request.getAttribute("urlParameter2");
	if( nodeType.equals("ORMF") ){
		request.setAttribute("databaseList","0|File SQL");
	}

	boolean editRight = (""+request.getAttribute("editRight")).equals("true");
	String[] databaseList = (""+request.getAttribute("databaseList")).split(",");
	
%>

<silk:App title="ORM Editor" timeout="false" >

	<script src="{contextPath}/silk/silkDev.min.js?loadTime={loadTime}3"></script>
	
	<style>
		
		xxxxhr {
			border-color: #446C26;
		}
		
		.xxxxCodeMirror {
			border-radius: 4px;
			border: 4px solid white;
			padding: 0px 0px;
			font-size: 0.95em;
		}
		
		.xxxctab-pane {
			padding: 10px 2px;
		}
		
		.silk-content .group {
			font-size: 1.2em;
			padding-bottom: 8px;
			margin-bottom: 0px;
		}
		
		.xxxxbottom-line {
			border-bottom: 2px solid #91a1a9;
		}
		
		.table-active > td {
			background-color: var(--silk-header-bg);
		}
		
		#queryForm {
			padding-bottom: 0px;
		}

		.silk-nav-tabs {
			cmargin-top: 5px;
		}
			
	</style>
	
	<silk:JScode>
		var formPage = "B";
		
		getPage = function(){
			return formPage;
		}
	</silk:JScode>
	
	<silk:Screen>
		<%@ include file="editorORM/moduleSummary.jsp" %>
		<%@ include file="editorORM/moduleTable.jsp" %>
		<%@ include file="editorORM/moduleColumn.jsp" %>
		<%@ include file="editorORM/moduleSelect.jsp" %>
		<%@ include file="editorORM/moduleOperation.jsp" %>
		<%@ include file="editorORM/moduleAuthorization.jsp" %>
		<%@ include file="editorORM/moduleFx.jsp" %>
		<%@ include file="editorORM/moduleDoc.jsp" %>
		<%@ include file="editorORM/moduleCopy.jsp" %>
		<%@ include file="editorORM/moduleImport.jsp" %>
	</silk:Screen>

	<silk:DataProvider id="databaseDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="targetDatabaseList"
		loadingOrder="1"
		renderIf="${urlParameter2}=ORM"
	/>

	<silk:DataProvider id="databaseDP" pkColumn="silkDatabaseID" renderIf="${urlParameter2}=ORMF" >
		{"silkDatabaseID":"0","databaseName":"File SQL", "position":"1"}
	</silk:DataProvider>
			
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" autoLoad="false" />
	
	<silk:JScode>
		var ormVersion = "2";
		var ormObject = new Object();
		var xmlJSON;
		var createSQL;
		var toSave = false;
		var databaseID = 1;
		var silkProjectID = "${urlParameter0}";
		var silkSystemID = "${urlParameter1}";
	</silk:JScode>
	
	<silk:JQcode>
		
		silk.on("afterDPLoad",function(){
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
		});
		
		databaseDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
		});
		
		databaseDP.on("afterSelect", function(){
			var databaseList = "${databaseList}";
			for( x=0; x<databaseDP.size(); x++ ){
				let dbID = databaseDP.getItemAt(x).silkDatabaseID;
				var active = 0;
				if( databaseList.indexOf(dbID+"|")>-1 ){
					active = 1;
				}
				databaseDP.setItemAt(x,"active",active);
			}
			contentDP.select();
		});
		
	</silk:JQcode>

	<silk:JQcode>
		
		contentDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", silkProjectID );
		});
		
		contentDP.on("afterSelect", function(){
			if( contentDP.size()==0 ){
				var ormType = "ORM";
				<silk:If renderIf="${urlParameter2}=ORMF" >
					ormType = "ORMF";
				</silk:If>
				contentLoading("{ \"queryType\": \"SQL\", \"table\": {}, \"column\": [], \"select\": [], \"operation\": [], \"authorization\": [], \"fk\": [] }");				
			}else{
				contentLoading(contentDP.getItem().content);
			}
		});

		contentLoading = function(jsonText){
			/*
			 * Loads the JSON content into the main object.
			 */
			ormObject = JSON.parse( jsonText );
			
			loadOrmObject();
			
			setSqlEditor();

			<silk:If renderIf="${urlParameter2}=ORM" >
				if( tableForm.tableName.getValue()=="" ) tableForm.setUpdate();
			</silk:If>
		};
		
	</silk:JQcode>

	<silk:JQcode>
		
		tableForm.on("afterLoad", function(){
			setDevelopmentDatabase();
		});
		
		/*
		 * Loads the development database indentifier and the testing database label
		 */
		setDevelopmentDatabase = function(){
			
			<silk:If renderIf="${urlParameter2}=ORM" >
				/*
				 * Gets databaseID from the tableForm
				 */
				databaseID = tableForm.developmentDatabaseID.getValue();
				if( ifUndefined(databaseID,0)==0 ){
					/*
					 * if databaseID is undefined
					 */
					if( contentDP.size()==0 ){
						/*
						 * if contentDP size if zeron it loads first database from the list.
						 */
						databaseID = databaseDP.getItem().silkDatabaseID;
					}else{
						/*
						 * Load the default development database
						 */
						databaseID = contentDP.getItem().silkDatabaseID;
						
						if ( databaseDP.getIndex( contentDP.getItem().databaseID )==-1 ){
							/*
							 * If the loaded database does not exist in the database list is load the firs one.
							 */
							databaseID = databaseDP.getItem().silkDatabaseID;
						}
					}
				}
			</silk:If>
				   
			<silk:If renderIf="${urlParameter2}=ORMF" >
				databaseID = 0;
			</silk:If>

			var databaseLabel = "Database: "+databaseDP.getIndexItem(databaseID).databaseName;
			if( tableForm.developmentDatabaseID.getValue()==0 ) databaseLabel += " (System)";

			queryForm.developmentDB.setValue( databaseLabel );
		};
		
		/*
		 * Set SQL Editors
		 */
		setSqlEditor = function(){
			let databaseList = tableForm.editorDatabaseID.getValue();
			activateTargetTab("tableDBTab", databaseList);
			activateTargetTab("typeTab", databaseList);
			activateTargetTab("selectSQLTab", databaseList);
			activateTargetTab("operationSQLTab", databaseList);
			activateTargetTab("authorizationSQLTab", databaseList);			
		}
		
		/*
		 * Activate target
		 */
		 activateTargetTab = function(targetTab,databaseList){
			let activeID = "";
			for(x=0; x<databaseDP.size(); x++){
				let tabID = targetTab+databaseDP.getItemAt(x).silkDatabaseID;
				let visible = databaseList.indexOf(","+databaseDP.getItemAt(x).silkDatabaseID+",")>-1;
				window[targetTab].toggleTab(tabID, visible);
				if( visible && window[targetTab].getActive(tabID) ) activeID = tabID;
			}
			if( activeID=="" ){
				for( x in window[targetTab].getTabs() ){
					if( window[targetTab].getVisible(x) ){
						window[targetTab].setIndex(x);
						break;
					}
				}
			}
		}
		
		/*
		 * Returns if the selected SQL type matches the parameter
		 */
		getViewSQL = function(type){
			if( queryForm.queryType.getValue() != "SQL" ) return false;
			if( type==undefined ) return false;
			return queryForm.dbType.getValue()==type;
		}
		
		/*
		 * Loads ormObject element into different objects.
		 */
		loadOrmObject = function(){
			
			/*
			 * Sets the query type in the form.
			 */
			if( queryForm.queryType==undefined ) queryForm.queryType = "SQL";
			queryForm.queryType.setValue( ormObject.queryType );
			
			/*
			 * Load Table
			 */
			var tableList = new Array()
			tableList.push(ormObject.table);
			tableDP.selectObject.data = tableList;
			
			/*
			 * Setting editor tab based on system database.
			 */
			var editorList = ifUndefined(tableDP.selectObject.data[0].editorDatabaseID,'');
			if( editorList.indexOf( ","+contentDP.getSelectedItem().silkDatabaseID+"," ) ){
				tableDP.selectObject.data[0].editorDatabaseID += ","+contentDP.getSelectedItem().silkDatabaseID+",";
			}

			<silk:If renderIf="${urlParameter2}=ORMF" >
				tableDP.selectObject.data[0].editorDatabaseID = ",0,";
				tableDBTab.$content.hide();
				tableDBTab.$tab.hide();
			</silk:If>
			
			tableDP.load();
			
			
			/*
			 * Load columns into columnDP
			 */
			if( ormObject.column != undefined ){
				columnDP.selectObject.data = addID(ormObject.column);
				columnDP.load();
				
				<silk:If renderIf="${urlParameter2}=ORMF" >
					typeTab.$content.hide();
					typeTab.$tab.hide();
					columnTab.hideTab(1);
					columnTab.hideTab(2);
				</silk:If>
			}
			
			/*
			 * Load select into selectDP
			 */
			if( ormObject.select != undefined ){
				selectDP.selectObject.data = addID(ormObject.select);
				selectDP.load();
			}
			
			/*
			 * Load operation into operationDP
			 */
			if( ormObject.operation != undefined ){
				operationDP.selectObject.data = addID(ormObject.operation);
				operationDP.load();
			}
			
			/*
			 * Load authorization into authorizationDP
			 */
			if( ormObject.authorization != undefined ){
				authorizationDP.selectObject.data = addID(ormObject.authorization);
				authorizationDP.load();
				<silk:If renderIf="${urlParameter2}=ORMF" >
					authorizationList.hide();
				</silk:If>
			}
			
			/*
			 * Load fk into fkDP
			 */
			if( ormObject.fk != undefined ){
				fkDP.selectObject.data = addID(ormObject.fk);
				fkDP.load();
				<silk:If renderIf="${urlParameter2}=ORMF" >
					fkList.hide();
				</silk:If>
			}
			
		}
		
		/*
		 * Add the ID properlty if it does not exist in the object
		 */
		addID = function(array){
			for( x=0; x < array.length; x++ ){
				if( array[x].id==undefined){
					array[x]["id"] = getUUID();
				}
			}
			return array;
		}
		
		<silk:If renderIf="${editRight}" >
			
			/*
			 * Update DataProvider into ormObject before saving
			 */
			updateOrmObject = function(){
				ormObject.queryType = queryForm.queryType.getValue();
				ormObject.table = tableDP.selectObject.data[0];
				ormObject.column = columnDP.selectObject.data;
				ormObject.select = selectDP.selectObject.data;
				ormObject.operation = operationDP.selectObject.data;
				ormObject.authorization = authorizationDP.selectObject.data;
				ormObject["fk"] = fkDP.selectObject.data;
			}
			
			/*
			 * Save Function
			 */
			saveORM = function(){
				updateOrmObject();
				ormJSON = JSON.stringify(ormObject);
				
				contentDP.setParameter("silkProjectID", silkProjectID);
				contentDP.setParameter("content", ormJSON);
				contentDP.exec("updateContent");

			};
	
			/*
			 * Saves content into files
			 */
			contentDP.on("afterExec", function(){
				let url = "{contextPath}/service/SilkBuilderIDE/system/saveCode";
				$.ajax({
					url: url,
					data: { silkProjectID : silkProjectID },
					success: function(data) {},
					error: function() {},
					type: 'POST'
				});
			});

		</silk:If> 
		
	</silk:JQcode>
	
</silk:App>
