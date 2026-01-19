<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="authorizationFormPage" stage="F" returnPage="summaryPage"
		smLayout="F:*:b"
		mdLayout="F:*:b"
		rgLayout="A:400px,F"
		lgLayout="A:400px,F"
		xlLayout="A:400px,F"
		xxLayout="A:400px,F"		
	>
		<silk:Header >
			Authorization Info
		</silk:Header>
		<silk:Content>
			<silk:Form id="authorizationForm" dataSource="authorizationList" buttonTarget="null,authorizationFormPage"
				insertBt="authorizationAddBt" buttonTest="${editRight}"
				toggleEdit="!#authSqlDescription"
			>
				<silk:Input id="authorizationName" type="text" label="Authorization Name" required="true" />
				<silk:Tab id="authorizationSQLTab">
<%
				for( String database : databaseList){
					if( database.equals("") ) continue;
					String[] parts = database.split("\\|");
					String tabItemID = "authorizationSQLTab"+parts[0];
					String databaseName = parts[1];
					if( editRight ) databaseName += "&nbsp;&nbsp;<i class='fa-solid fa-copy copy-sql' ></i>";
					String sqlID = "sql"+parts[0];
%>
					
					<silk:TabItem id="<%=tabItemID%>" title="<%=databaseName%>">
						<silk:Input id="<%= sqlID %>" type="sql" />
					</silk:TabItem>
					<silk:JQcode>
						authorizationForm.<%= sqlID %>.on("modeChange",function(mode,$text,$value){
							if( mode ){
								authorizationForm.<%= sqlID %>.codeEditor.setLightTheme();
								$value.removeClass("silk-input-text");
								$value.addClass("silk-input-value");
							}else{
								authorizationForm.<%= sqlID %>.codeEditor.setDarkTheme();
								$value.addClass("silk-input-text");
								$value.removeClass("silk-input-value");
							}
						});
					</silk:JQcode>
					
<%				} %>
				</silk:Tab>
				<p id="authSqlDescription" >
					The SELECT command should return the column "result" with values 0 for Not Allow, and 1 for Allowed.
				</p>
				<silk:Input id="description" type="html" label="Description" />
				<silk:Input id="id" type="hidden" value="getAuthorizationID()" />
			</silk:Form>
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="authorizationDP" pkColumn="id" />

	<silk:JQcode>
		
		authorizationList.on("click", function(){
			unselectList("authorizationList");
		})
		
		getAuthorizationID = function(){
			if( authorizationForm.getAction()=="insert" ) return getUUID();
			return authorizationList.getSelectedItem().id;
		}
		
		authorizationFormPage.on("show", function(){
			formPage="F";
		});
		
		authorizationDP.on("afterLoad", function(action){
			if(action=="select") return;
			saveORM();
		});

		authorizationSQLTab.on("click", function(index, tabID, element){
			if( $(element).hasClass("copy-sql") ){
				copyForm = "authorizationForm";
				copyTo = getNumber(authorizationSQLTab.getSelectedTab().id);
				copySelectModal.show(event.pageX, event.pageY, 200);
			};
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
		authorizationSQLTab.on("click", function(index){
			typeTab.setIndex(index,false);
			selectSQLTab.setIndex(index,false);
			operationSQLTab.setIndex(index,false);
			tableDBTab.setIndex(index,false);
		});
	</silk:JQcode>

</silk:Module>