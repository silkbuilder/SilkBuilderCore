<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="selectFormPage" stage="D" returnPage="summaryPage"
		smLayout="D:*:b"
		mdLayout="D:*:b"
		rgLayout="A:400px,D"
		lgLayout="A:400px,D"
		xlLayout="A:400px,D"
		xxLayout="A:400px,D"		
	>
		<silk:Header >
			Select Info
		</silk:Header>
		<silk:Content>
			<silk:Form id="selectForm" dataSource="selectList" buttonTarget="null,selectFormPage" insertBt="selectAddBt" buttonTest="${editRight}" >
				<silk:Input id="selectName" type="text" label="Select Name" required="true" width="50%" />
				<silk:Input id="origin" type="select" label="Origin" dataSource="originDP" width="49%" renderIf="${urlParameter2}=ORM" />
				<silk:Tab id="selectSQLTab">
<%
				for( String database : databaseList){
					if( database.equals("") ) continue;
					String[] parts = database.split("\\|");
					String tabItemID = "selectSQLTab"+parts[0];
					String databaseName = parts[1];
					if( editRight ) databaseName += "&nbsp;&nbsp;<i class='fa-solid fa-copy copy-sql' ></i>";
					String sqlID = "sql"+parts[0];
%>
					
					<silk:TabItem id="<%= tabItemID %>" title="<%=databaseName%>">
						<silk:Input id="<%= sqlID %>" type="sql" />
					</silk:TabItem>
					<silk:JQcode>
						selectForm.<%= sqlID %>.on("modeChange",function(mode,$text,$value){
							if( mode ){
								selectForm.<%= sqlID %>.codeEditor.setLightTheme();
								$value.removeClass("silk-input-text");
								$value.addClass("silk-input-value");
							}else{
								selectForm.<%= sqlID %>.codeEditor.setDarkTheme();
								$value.addClass("silk-input-text");
								$value.removeClass("silk-input-value");
							}
						});
					</silk:JQcode>
					
<%				} %>
				</silk:Tab>
				<silk:Input id="description" type="html" label="Description" height="100px" />
				<silk:Input id="id" type="hidden" value="getSelectID()" />
			</silk:Form>
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="originDP" pkColumn="origin" >
		{"origin":"0", "label":"ORM"},
		{"origin":"1", "label":"Database"}
	</silk:DataProvider>

	<silk:DataProvider id="selectDP" pkColumn="id" />

	<silk:JQcode>

		copySelectModal.$body.css("text-align","center");
		
		selectList.toggleSearch(false);
	
		selectList.on("click", function(){
			unselectList("selectList");
		});
		
		selectFilterBt.on("click", function(){
			selectList.toggleSearch();
		});
		
		getSelectID = function(){
			if( selectForm.getAction()=="insert" ) return getUUID();
			return selectList.getSelectedItem().id;
		}
		
		selectFormPage.on("show", function(){
			formPage="D";
		});
		
		selectFormPage.on("beforeModeChange", function(mode){
			
		});
		
		selectDP.on("afterLoad", function(action){
			if(action=="select") return;
			saveORM();
		});

		selectSQLTab.on("click", function(index, tabID, element){
			if( $(element).hasClass("copy-sql") ){
				copyForm = "selectForm";
				copyTo = getNumber(selectSQLTab.getSelectedTab().id);
				position = selectSQLTab.getSelectedTab().$tab.position();
				copySelectModal.show(event.pageX, event.pageY, 200);
			};
		});

	</silk:JQcode>
	
	<silk:JQcode>
		selectSQLTab.on("click", function(index){
			typeTab.setIndex(index,false);
			tableDBTab.setIndex(index,false);
			operationSQLTab.setIndex(index,false);
			authorizationSQLTab.setIndex(index,false);
		});
	</silk:JQcode>
	
</silk:Module>