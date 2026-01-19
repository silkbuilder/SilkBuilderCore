<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="operationFormPage" stage="E" returnPage="summaryPage"
		smLayout="E:*:b"
		mdLayout="E:*:b"
		rgLayout="A:400px,E"
		lgLayout="A:400px,E"
		xlLayout="A:400px,E"
		xxLayout="A:400px,E"		
	>
		<silk:Header >
			Operation Info
		</silk:Header>
		<silk:Content>
			<silk:Form id="operationForm" dataSource="operationList" buttonTarget="null,operationFormPage" insertBt="operationAddBt" buttonTest="${editRight}" >
			
				<silk:Input id="type" type="select" label="Type" dataSource="operationTypeDP" required="true"
					valueColumn="type" labelColumn="typeLabel" width="200px"
				 />
			
				<silk:Input id="operationName" type="text" label="Operation Name" width="300px"
					required="operationForm.type.getValue()=='exec'"
					visible="operationForm.type.getValue()=='exec'"
				 />
				 
				<silk:Input id="when" type="select" label="When" dataSource="operationWhenDP"
					valueColumn="when" labelColumn="whenLabel" width="200px"
					required="operationForm.type.getValue()=='trigger'"
					visible="operationForm.type.getValue()=='trigger'"
				 />
				
				<silk:Input id="action" type="select" label="Action" dataSource="operationActionDP"
					valueColumn="action" labelColumn="actionLabel" width="200px"
					required="operationForm.type.getValue()=='trigger'"
					visible="operationForm.type.getValue()=='trigger'"
				 />
				 
				<silk:Input id="origin" type="select" label="Origin" dataSource="originDP" width="150px" />
				
				<silk:Tab id="operationSQLTab">
<%
				for( String database : databaseList){
					if( database.equals("") ) continue;
					String[] parts = database.split("\\|");
					String tabItemID = "operationSQLTab"+parts[0];
					String databaseName = parts[1];
					if( editRight ) databaseName += "&nbsp;&nbsp;<i class='fa-solid fa-copy copy-sql' ></i>";
					String sqlID = "sql"+parts[0];
%>
					
					<silk:TabItem id="<%=tabItemID%>" title="<%=databaseName%>">
						<silk:Input id="<%= sqlID %>" type="sql" />
					</silk:TabItem>
					<silk:JQcode>
						operationForm.<%= sqlID %>.on("modeChange",function(mode,$text,$value){
							if( mode ){
								operationForm.<%= sqlID %>.codeEditor.setLightTheme();
								$value.removeClass("silk-input-text");
								$value.addClass("silk-input-value");
							}else{
								operationForm.<%= sqlID %>.codeEditor.setDarkTheme();
								$value.addClass("silk-input-text");
								$value.removeClass("silk-input-value");
							}
						});
					</silk:JQcode>
<%				} %>
				</silk:Tab>
				
				<hr/>
				
				<silk:Input id="reportZeroResult" type="checkBox" label="Report zero results" />
				<silk:Input id="authorization" type="text" label="Authorization" visible="operationForm.type.getValue()=='exec'" />
				<silk:Input id="description" type="html" label="Description" />
				
				<silk:Input id="id" type="hidden" value="getOperationID()" />
			</silk:Form>
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="operationDP" pkColumn="id" />

	<silk:DataProvider id="operationTypeDP" >
		{"type":"exec", "typeLabel":"Exec Operation"},
		{"type":"trigger", "typeLabel":"Trigger"}
	</silk:DataProvider>

	<silk:DataProvider id="operationActionDP" >
		{"action":"select", "actionLabel":"Select"},
		{"action":"insert", "actionLabel":"Insert"},
		{"action":"update", "actionLabel":"Update"},
		{"action":"delete", "actionLabel":"Delete"},
		{"action":"batch", "actionLabel":"Batch"}
	</silk:DataProvider>

	<silk:DataProvider id="operationWhenDP" >
		{"when":"before", "whenLabel":"Before"},
		{"when":"after", "whenLabel":"After"}
	</silk:DataProvider>

	<silk:JQcode>
		
		operationList.toggleSearch(false);
		
		operationList.on("click", function(){
			unselectList("operationList");
		});
		
		operationFilterBt.on("click", function(){
			operationList.toggleSearch();
		});
		
		getOperationID = function(){
			if( operationForm.getAction()=="insert" ) return getUUID();
			return operationList.getSelectedItem().id;
		}
	
		operationFormPage.on("show", function(){
			formPage="E";
		});
		
		operationDP.on("afterLoad", function(action){
			if(action=="select") return;
			saveORM();
		});

		operationSQLTab.on("click", function(index, tabID, element){
			if( $(element).hasClass("copy-sql") ){
				copyForm = "operationForm";
				copyTo = getNumber(operationSQLTab.getSelectedTab().id);
				copySelectModal.show(event.pageX, event.pageY, 200);
			};
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
		operationSQLTab.on("click", function(index){
			typeTab.setIndex(index,false);
			selectSQLTab.setIndex(index,false);
			tableDBTab.setIndex(index,false);
			authorizationSQLTab.setIndex(index,false);
		});
	</silk:JQcode>

</silk:Module>