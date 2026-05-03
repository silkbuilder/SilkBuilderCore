<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="columnFormPage" stage="C" returnPage="summaryPage"
		smLayout="C:*:b"
		mdLayout="C:*:b"
		rgLayout="A:400px,C"
		lgLayout="A:400px,C"
		xlLayout="A:400px,C"
		xxLayout="A:400px,C"		
	>
		<silk:Header >
			Column Info
		</silk:Header>
		<silk:Content>
			<silk:Form id="columnForm" dataSource="columnList" buttonTarget="null,columnFormPage" insertBt="columnAddBt" buttonTest="${editRight}"
				toggleEdit="#columnSQLBt, #columnExportBt"
			>
				
				<silk:Tab id="columnTab">
					<silk:TabItem title="General">
						
						<div>
							<silk:Input id="columnName" type="text" label="Column Name" width="300px" required="true" />
							
							<silk:Input id="type" type="select" label="ORM Type" dataSource="columnTypeDP" required="true"
								valueColumn="columnTypeID" labelColumn="columnTypeLabel" width="200px"
							/>
							 
							<silk:Input id="pk" type="checkbox" label="Primary Key" width="120px"
								visible="( columnForm.pk.getValue()==1 ) ? true : columnDP.getIndexOf('pk','1')<0 "
							/>
							<silk:Input id="pkNotSecure" type="checkbox" label="Not Secure" width="120px"
								visible="columnForm.pk.getValue()==1 && queryForm.queryType.getValue()=='SQL'"
							/>
							<silk:Input id="secure" type="checkbox" label="Secure" width="100px"
								visible="columnForm.pk.getValue()==0 && queryForm.queryType.getValue()=='SQL'"
							/>
							<silk:Input id="notNull" type="checkBox" label="Not&nbsp;Null" width="100px"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
							<silk:Input id="unique" type="checkBox" label="Unique" width="90px"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
							<silk:Input id="indexColumn" type="checkBox" label="Index Column" width="200px"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
						</div>
						<div>
							<silk:Input id="nullValue" type="text" label="ORM Null Value" width="200px"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
							<silk:Input id="role" type="select" label="Functional Roles" dataSource="columnRoleDP"
								valueColumn="columnRoleID" labelColumn="columnRoleLabel" width="300px"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
						</div>
						<div>
							<silk:Input id="functionModifiers" type="checkbox" label="Uses Function Modifiers"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
						</div>
						
						<silk:Tab id="typeTab">
<%
						for( String database : databaseList){
							if( database.equals("") ) continue;
							String[] parts = database.split("\\|");
							String tabItemID = "typeTab"+parts[0];
							String databaseName = parts[1];
							if( editRight ) databaseName += "&nbsp;&nbsp;<i class='fa-solid fa-copy copy-sql' ></i>";
							String sqlTypeID = "sqlType"+parts[0];
							String defaultValueID = "defaultValue"+parts[0];
							String functionID = "function"+parts[0];
							String functionInsertID = "functionInsert"+parts[0];
							String functionUpdateID = "functionUpdate"+parts[0];
%>
							
							<silk:TabItem id="<%=tabItemID%>" title="<%=databaseName%>" >
								<silk:Input id="<%=sqlTypeID%>" type="text" label="Database Type" width="200px"  />
								<silk:Input id="<%=defaultValueID%>" type="text" label="Default Value" width="200px" block="true" />								 
								<silk:Input id="<%=functionID%>" type="text" label="General" width="200px" visible="columnForm.functionModifiers.getValue()==1" />
								<silk:Input id="<%=functionInsertID%>" type="text" label="On Insert" width="200px" visible="columnForm.functionModifiers.getValue()==1" />
								<silk:Input id="<%=functionUpdateID%>" type="text" label="On Update" width="200px" visible="columnForm.functionModifiers.getValue()==1" />
							</silk:TabItem>								
							
<%						} %>

						</silk:Tab>
						
						<hr/>
						
						<silk:Input id="description" type="html" label="Description" height="100px" />
						
					</silk:TabItem>
					<silk:TabItem title="Foreign Key">

						 
						 <silk:Input id="fkTable" type="text" label="FK Table" width="200px" />
						 <silk:Input id="fkColumn" type="text" label="FK Column" width="200px" block="true"
						 	visible="columnForm.fkTable.getValue()!=''"
						  />
						 
						<silk:Input id="fkMatch" type="select" label="FK Match Type" dataSource="fkMatchDP"
							valueColumn="fkMatchID" labelColumn="fkMatchLabel" width="200px"
							visible="columnForm.fkTable.getValue()!=''"
						 />
						 
						 <silk:Input id="fkOnUpdate" type="select" label="FK On Update" dataSource="fkOnDP"
							valueColumn="fkOnID" labelColumn="fkOnLabel" width="200px"
							visible="columnForm.fkTable.getValue()!=''"
						 />
						 
						 <silk:Input id="fkOnDelete" type="select" label="FK On Delete" dataSource="fkOnDP"
							valueColumn="fkOnID" labelColumn="fkOnLabel" width="200px"
							visible="columnForm.fkTable.getValue()!=''"
						 />
						 
					</silk:TabItem>
					<silk:TabItem title="Data Mangement">
						<div>
							<silk:Input id="translation" type="select" label="Translation" dataSource="columnTranslationDP"
								valueColumn="columnTranslationID" labelColumn="columnTranslationLabel" width="300px"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
						</div>
						<div>
							<silk:Input id="validation" type="text" label="Validation (Regex)" width="450px"
								visible="queryForm.queryType.getValue()=='SQL'"
							/>
						</div>
						<silk:Input id="authorization" type="text" label="Authorization" block="true" />
					</silk:TabItem>
					
					<silk:Input id="id" type="hidden" value="getColumnID()" />
					
				</silk:Tab>
				 
			</silk:Form>
			
			<hr/>

			<silk:If renderIf="${urlParameter2}=ORM" >
				<div align="center">
					<silk:Button id="columnSQLBt" label="SQL" targetPage="alterModal" renderIf="${editRight}"  />
					<silk:Button id="columnExportBt" label="Exp" targetPage="alterModal" renderIf="${editRight}" /> 
				</div>
			</silk:If>
						 
		</silk:Content>
	</silk:Page>

	<silk:Modal id="alterModal" title="Alter Table SQL" size="large" closeButton="true" bodyMargin="false" >
		<silk:Input id="alterCode" type="sql" />
	</silk:Modal>

	<silk:DataProvider id="columnDP" pkColumn="id" />

	<silk:DataProvider id="columnTypeDP" >
		{"columnTypeID":"S", "columnTypeLabel":"String"},
		{"columnTypeID":"I", "columnTypeLabel":"Integer"},
		{"columnTypeID":"N", "columnTypeLabel":"Numeric"},
		{"columnTypeID":"D", "columnTypeLabel":"Date/Time"},
		{"columnTypeID":"P", "columnTypeLabel":"Password"},
		{"columnTypeID":"U", "columnTypeLabel":"UUID (String)"},
		{"columnTypeID":"X", "columnTypeLabel":"Public ID (String)"},
	</silk:DataProvider>

	<silk:DataProvider id="columnRoleDP" >
		{"columnRoleID":"X", "columnRoleLabel":"N.A."},
		{"columnRoleID":"R", "columnRoleLabel":"Tree Root (If different than Primary Key)"},
		{"columnRoleID":"P", "columnRoleLabel":"Tree Parent"},
		{"columnRoleID":"L", "columnRoleLabel":"Tree Level"},
		{"columnRoleID":"O", "columnRoleLabel":"Row Ordering"},
		{"columnRoleID":"S", "columnRoleLabel":"Operation Status"},
		{"columnRoleID":"A", "columnRoleLabel":"Operation Action"},
		{"columnRoleID":"D", "columnRoleLabel":"Operation Date"},
		{"columnRoleID":"U", "columnRoleLabel":"Operation User"}
	</silk:DataProvider>

	<silk:DataProvider id="columnTranslationDP" >
		{"columnTranslationID":"0", "columnTranslationLabel":"None"},
		{"columnTranslationID":"1", "columnTranslationLabel":"In Column data"},
		{"columnTranslationID":"2", "columnTranslationLabel":"By Columns"}
	</silk:DataProvider>
	
	<silk:DataProvider id="fkMatchDP" >
		{"fkMatchID":"0", "fkMatchLabel":"Simple"},
		{"fkMatchID":"1", "fkMatchLabel":"Full"},
		{"fkMatchID":"2", "fkMatchLabel":"Partial"}
	</silk:DataProvider>

	<silk:DataProvider id="fkOnDP" >
		{"fkOnID":"0", "fkOnLabel":"No Action"},
		{"fkOnID":"1", "fkOnLabel":"Cascade"},
		{"fkOnID":"2", "fkOnLabel":"Set Null"},
		{"fkOnID":"3", "fkOnLabel":"Set Default"},
		{"fkOnID":"4", "fkOnLabel":"Restrict"}
	</silk:DataProvider>

	<silk:JScode>
	
		renderType = function(index,item,data){
			if( data=="") return "";
			return columnTypeDP.getIndexItemOf("columnTypeID",data).columnTypeLabel
		}
		
		renderPK = function(index,item,data){
			if( item.pk==1 ) return "<i class='fas fa-key'></i>";
			if( item.secure==1 ) return "<i class='fas fa-lock'></i>";
			return "";
		}
		
	</silk:JScode>

	<silk:JQcode>

		columnList.toggleSearch(false);
	
		alterCode.codeEditor.setDarkTheme();
		alterCode.$dataField.attr("class","");
		alterCode.$dataField.parent().attr("class","");
		alterCode.$dataField.parent().css("margin","0");
	
		columnList.on("click", function(){
			unselectList("columnList");
			columnTab.setIndex(0);
		});
	
		columnFilterBt.on("click", function(){
			columnList.toggleSearch();
		});
		
		getColumnID = function(){
			if( columnForm.getAction()=="insert" ) return getUUID();
			return columnList.getSelectedItem().id;
		}
		
		
		columnForm.on("insert",function(){
			columnTab.setIndex(0);
		});
		
		columnFormPage.on("show", function(){
			formPage="C";
		});
		
		columnDP.on("afterLoad", function(action){
			extractColumnBt.toggle(columnDP.size()>0);
			importColumnBt.toggle(columnDP.size()==0);
			if(action=="select") return;
			saveORM();
		});

		columnList.on("dragDrop", function(){
			saveORM();
		});
		
		alterModal.on("show",function(){
			
			var columnType = "";
			var defaultValue = "";
			var hasForeing = false;
			var fkCode = ""
			
			for(var x=0; x < ormObject.column.length; x++){
				var column = ormObject.column[x];
				if( column.columnName==columnForm.columnName.getValue() ){
					columnType = column["sqlType"+databaseID];
					var defaultValue = column["defaultValue"+databaseID];
					
					if( ifUndefined(column.fkTable,"")!="" ){
						hasForeing = true;
						fkCode = "\tforeign key ("+column.columnName+") references "+column.fkTable+" ("+column.fkColumn+") ";
						if( ifUndefined(column.fkMatch,"0")!='0' ) fkCode += "match "+fkMatchDP.getItemAt(column.fkMatch,"fkMatchLabel")+" ";
						if( ifUndefined(column.fkOnUpdate,"0")!='0' ) fkCode += "on delete "+fkOnDP.getItemAt(column.fkOnUpdate,"fkOnLabel")+" ";
						if( ifUndefined(column.fkOnDelete,"0")!='0' ) fkCode += "on delete "+fkOnDP.getItemAt(column.fkOnDelete,"fkOnLabel")+" ";
					}
					
				}
			}
			
			var sqlCode = "alter table "+ormObject.table.tableName+" add "+columnForm.columnName.getValue()+" "+columnType;
			if( ifUndefined(defaultValue,"")!="" ) sqlCode += " default "+defaultValue;
			if( hasForeing ) sqlCode += "\n"+fkCode;
			sqlCode += ';'

			if( columnForm.indexColumn.getValue() == 1 ) {
				sqlCode += "\ncreate index " + ormObject.table.tableName + "_" + columnForm.columnName.getValue() + " on " + ormObject.table.tableName + "(" + columnForm.columnName.getValue() + ");\n";
			}

			
			sqlCode = sqlCode.replaceAll("\{dbTable\}", ormObject.table.tableName);
			
			alterCode.setValue( sqlCode );
		});

		typeTab.on("click", function(index, tabID, element){
			if( $(element).hasClass("copy-sql") ){
				copyForm = "columnForm";
				copyTo = getNumber(typeTab.getSelectedTab().id);
				copySelectModal.show(event.pageX, event.pageY, 250);
			};
		});

	</silk:JQcode>

	<silk:JQcode>
		typeTab.on("click", function(index){
			tableDBTab.setIndex(index,false);
			selectSQLTab.setIndex(index,false);
			operationSQLTab.setIndex(index,false);
			authorizationSQLTab.setIndex(index,false);
		});
	</silk:JQcode>
</silk:Module>