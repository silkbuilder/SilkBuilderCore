<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<style>
		#exportCode, #importCode {
			margin: 0px;
		}
	</style>
	
	<silk:Page id="tableFormPage" stage="B" returnPage="summaryPage"
		smLayout="B:*:b"
		mdLayout="B:*:b"
		rgLayout="A:400px,B"
		lgLayout="A:400px,B"
		xlLayout="A:400px,B"
		xxLayout="A:400px,B"
	>
		<silk:Header >
			Table Info
		</silk:Header>
		<silk:Content>
			<silk:Form id="tableForm" dataSource="tableList" buttonTarget="null,tableFormPage,null" buttonTest="${editRight}"
				toggleEdit="#tableOptionsBox,!#tableAuthDescription"
			>
				<p id="tableAuthDescription">
					The authorization SQL or session variable name formatted as "variable:value".
					These could be multiple items separated by commas.
				</p>
				
				<silk:Tab id="tableTab">
					<silk:TabItem title="General">

						<silk:If renderIf="${urlParameter2}=ORM" >
							<silk:Input id="tableName" type="text" label="Table Name" width="40%" scope="0" />
						</silk:If>

						<silk:If renderIf="${urlParameter2}=ORMF" >
							<silk:Input id="tableName" type="text" label="Path" scope="0" />
						</silk:If>

						<silk:Input id="pkMode" type="select" label="Primary Key Mode" dataSource="pkModeDP" scope="0"
							width="40%"
							valueColumn="pkModeID" labelColumn="pkModeLabel"
							renderIf="${urlParameter2}=ORM"
						 />

						<silk:Input id="log" type="checkbox" label="Log Transaction"
							width="20%"
							block="true"
							renderIf="${urlParameter2}=ORM"
						/>
						
						<silk:Input id="developmentDatabaseID" type="select" label="Development Database" scope="0"
							width="50%"
							dataSource="databaseDP"
							valueColumn="silkDatabaseID"
							labelColumn="databaseName"
							prompt="Use system database"
							promptValue="0"
							visible="tableForm.developmentDatabaseID.getValue()!='0' || tableForm.getAction()=='update'"
							renderIf="${urlParameter2}=ORM"
						/>

						<silk:Input id="databaseController" type="text" label="Production Controller" width="50%" scope="0"
							placeholder="Empty to use the default database controller."
							visible="tableForm.databaseController.getValue()!='' || tableForm.getAction()=='update'"
							renderIf="${urlParameter2}=ORM"
						/>
						
						<silk:Input id="editorDatabaseID" type="options" label="Database Editors" required="true" scope="0"
							itemsDirection="horizontal"
							dataSource="databaseDP"
							valueColumn="silkDatabaseID"
							labelColumn="databaseName"
							visible="queryForm.queryType.getValue()=='SQL' && tableForm.getAction()=='update' && databaseDP.size()>1"
						/>
						
						<silk:Tab id="tableDBTab" >
<%
						for( String database : databaseList){
							if( database.equals("") ) continue;
							String[] parts = database.split("\\|");
							String tabItemID = "tableDBTab"+parts[0];
							String databaseName = parts[1];
							String dbSchemaID = "dbSchema"+parts[0];
							String sqlID = "pkSql"+parts[0];
%>
							
							<silk:TabItem id="<%=tabItemID%>" title="<%=databaseName%>" >
								<silk:Input id="<%=dbSchemaID%>" type="text" label="Database Schema" width="300px"  scope="0" />
								<silk:Input id="<%=sqlID%>" type="sql" label="SQL PK Generator" scope="0"
									visible="tableForm.pkMode.getValue()=='SQL' && queryForm.queryType.getValue()=='SQL'"
								/>
							</silk:TabItem>
							<silk:JQcode>
								tableForm.<%= sqlID %>.on("modeChange",function(mode,$text,$value){
									if( mode ){
										tableForm.<%= sqlID %>.codeEditor.setLightTheme();
										$value.removeClass("silk-input-text");
										$value.addClass("silk-input-value");
									}else{
										tableForm.<%= sqlID %>.codeEditor.setDarkTheme();
										$value.addClass("silk-input-text");
										$value.removeClass("silk-input-value");
									}
								});
							</silk:JQcode>
							
<%						} %>
						</silk:Tab>
						
						<silk:Input id="description" type="html" label="Description" />
					
					</silk:TabItem>
					<silk:TabItem title="Authorization">
						<silk:Input id="insertAuthorization" type="text" label="Insert Authorization" />
						<silk:Input id="updateAuthorization" type="text" label="Update Authorization" />
						<silk:Input id="deleteAuthorization" type="text" label="Delete Authorization" />
					</silk:TabItem>
				</silk:Tab>

			</silk:Form>

			<silk:If renderIf="${editRight}" >
				<div id="tableOptionsBox" align="center">
					<hr/>
					<silk:Button label="XML" targetPage="xmlModal" renderIf="false" />
					<silk:Button id="sqlViewBt" label="SQL" targetPage="createModal" renderIf="${urlParameter2}=ORM" />
					<silk:Button label="Exp" targetPage="exportModal" />
					<silk:Button label="Imp" targetPage="importModal" />
				</div>
				<br/>
			</silk:If>
			
		</silk:Content>
	</silk:Page>

	<silk:Modal id="xmlModal" title="ORM XML" size="large" closeButton="true" bodyMargin="false" >
		<silk:Input id="xmlCode" type="xml" />
	</silk:Modal>

	<silk:Modal id="createModal" title="Create Table SQL" size="large" closeButton="true" bodyMargin="false" >
		<silk:ModalBody>
			<silk:Input id="createCode" type="sql" />
		</silk:ModalBody>
		<silk:ModalFooter>
			<silk:Button id="copySQLBt" label="Copy to Clipboard" />
		</silk:ModalFooter>
	</silk:Modal>

	<silk:Modal id="exportModal" title="Export JSON" size="large" closeButton="true" >
		<silk:ModalBody>
			<silk:Input id="exportCode" type="code" mode="true" extraProperties="readonly" height="500px" />
		</silk:ModalBody>
		<silk:ModalFooter>
			<silk:Button id="copyJsonBt" label="Copy to Clipboard" />
		</silk:ModalFooter>
	</silk:Modal>

	<silk:Modal id="importModal" title="Import JSON" size="large" closeButton="true" >
		<silk:ModalBody>
			<silk:Input id="importCode" type="code" mode="true" height="500px" />
		</silk:ModalBody>
		<silk:ModalFooter>
			<silk:Button id="importBt" label="import" />
		</silk:ModalFooter>
	</silk:Modal>

	
	<silk:DataProvider id="tableDP" pkColumn="tableName" />

	<silk:DataProvider id="pkModeDP" >
		{"pkModeID":"Auto", "pkModeLabel":"Auto increment by database"},
		{"pkModeID":"SQL", "pkModeLabel":"SQL query"},
		{"pkModeID":"Value", "pkModeLabel":"Value provided"},
		{"pkModeID":"UUID", "pkModeLabel":"UUID auto generated"}
	</silk:DataProvider>

	<silk:JQcode>
		
		tableList.on("click", function(){
			tableTab.setIndex(0);
			unselectList("tableList");
		});
	
		tableFormPage.on("show", function(){
			formPage="B";
		});

		tableDP.on("afterUpdate", function(){
			setDevelopmentDatabase();
			saveORM();
		});
		
		tableForm.editorDatabaseID.on("change",function(){
			setSqlEditor();
		});
		
	</silk:JQcode>

	<silk:JQcode>
		
		xmlModal.on("show", function(){
			updateOrmObject();
			xmlCode.setValue(generateXML("${urlParameter2}"));
		});
		
		createModal.on("show", function(){
			updateOrmObject();
			generateCreateTableSQL(
				ormObject.table,
				ormObject.column,
				getNumber(tableDBTab.getSelectedTab().id)
			);
			createCode.setValue(createSQL.trim());
		});

		copySQLBt.on("click", function(){
			navigator.clipboard.writeText(createCode.getValue());
			silk.toast("SQL copied to clipboard");
		});

		
		exportModal.on("show", function(){
			updateOrmObject();
			exportCode.setValue(JSON.stringify(ormObject));
		});

		copyJsonBt.on("click", function(){
			navigator.clipboard.writeText(exportCode.getValue());
			silk.toast("JSON copied to clipboard");
		});
		
		importModal.on("show", function(){
			importCode.setValue("");
		});
		
		importBt.on("click", function(){
			var code = importCode.getValue();
			if( code=="" ) return;
			contentLoading(code);
			importModal.hide();
			saveORM();
			silk.toast("JSON imported");
		});
				
	</silk:JQcode>

	<silk:JQcode>
		tableDBTab.on("click", function(index){
			typeTab.setIndex(index, false);
			selectSQLTab.setIndex(index, false);
			operationSQLTab.setIndex(index, false);
			authorizationSQLTab.setIndex(index, false);
		});
	</silk:JQcode>
	
</silk:Module>
