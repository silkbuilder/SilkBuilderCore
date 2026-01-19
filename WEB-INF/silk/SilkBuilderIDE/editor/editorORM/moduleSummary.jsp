<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<style>
		#xextractColumnTab .nav-link.active {
			xbackground-color: #52575C;
			xborder-color: #446c26 #446c26 #52575C;
		}
	</style>
	
	<silk:Page id="summaryPage" stage="A"
		smLayout="A"
		mdLayout="A"
		rgLayout="A:400px,getPage()"
		lgLayout="A:400px,getPage()"
		xlLayout="A:400px,getPage()"
		xxLayout="A:400px,getPage()"
	>
		<silk:Header >
			
			<silk:If renderIf="${urlParameter2}=ORM" >
				ORM Table
			</silk:If>
			<silk:If renderIf="${urlParameter2}=ORMF" >
				ORM Folder
			</silk:If>
			
			<silk:Button icon="fa-regular fa-file-lines" dock="right" cssClass="btn-lg btn-link" cssStyle="color:#FFFFFF" targetPage="docModal" />
		</silk:Header>
		<silk:Content>
		
			<silk:Form id="queryForm" >
				<silk:Input id="queryType" type="hidden" />
				 <silk:Input id="developmentDB" type="text" editable="false" renderIf="${urlParameter2}=ORM" />
			</silk:Form>

			<silk:Table id="tableList" dataSource="tableDP" targetPage="tableFormPage" header="none" autoSelect="true" >
				<silk:Column  >
					<silk:If renderIf="${urlParameter2}=ORM" >
						TABLE
					</silk:If>
					<silk:If renderIf="${urlParameter2}=ORMF" >
						FOLDER
					</silk:If>					
					<i class="fas fa-angle-right"></i>&nbsp;
					<silk:If renderIf="${urlParameter2}=ORMF" >
						<span renderIf="'{tableName}'==''">Context Path</span>
					</silk:If>
					{tableName}
				</silk:Column>
				<silk:Column align="right" ><i class="fas fa-chevron-circle-right"></i></silk:Column>
			</silk:Table>
			
			<!--  Column -->
			<silk:Table id="columnList" dataSource="columnDP" title="Table Columns" targetPage="columnFormPage" header="inline"
				cssClass="table-sm xno-border" autoSelect="false" searchable="true"
			>
				<silk:TableHeader>
					<silk:Button id="columnFilterBt" icon="fa-solid fa-magnifying-glass" cssClass="btn-secondary btn-sm" dock="right" cssStyle="padding:0px 2px" />
					<silk:Button id="extractColumnBt" icon="fa-solid fa-code" cssClass="btn-primary btn-sm silk-hidden" dock="right" cssStyle="padding:0px 2px" renderIf="${editRight}" />
					<silk:Button id="importColumnBt" icon="fa-solid fa-database" cssClass="btn-success btn-sm silk-hidden" dock="right" cssStyle="padding:0px 2px" renderIf="${editRight}" targetPage="importColumnModal" />
					<silk:Button id="columnAddBt" icon="fa-solid fa-plus" cssClass="btn-primary btn-sm" dock="right" cssStyle="padding:0px 2px" renderIf="${editRight}" />
				</silk:TableHeader>
				
				<silk:TableBody>
					<silk:Column title="<i class='fas fa-sort'></i>" align="center" ordering="true" width="40px" />
					<silk:Column title="Name" >{columnName}</silk:Column>
					<silk:Column title="Type" renderer="renderType" >{type}</silk:Column>
					<silk:Column title="Key" renderer="renderPK" >{pk}</silk:Column>
					<silk:Column align="right" ><i class="fas fa-chevron-circle-right"></i></silk:Column>
				</silk:TableBody>
			</silk:Table>
			
			<!--  Select -->
			<br/>
			<silk:Table id="selectList" dataSource="selectDP" title="Selects" targetPage="selectFormPage" header="none"
				cssClass="table-sm xno-border" autoSelect="false" searchable="true"
			>
				<silk:TableHeader>
					<silk:Button id="selectFilterBt" icon="fa-solid fa-magnifying-glass" cssClass="btn-secondary btn-sm" dock="right" cssStyle="padding:0px 2px" />
					<silk:Button id="selectAddBt" icon="fas fa-plus" cssClass="btn-primary btn-sm" dock="right" cssStyle="padding:0px 2px" renderIf="${editRight}" />
				</silk:TableHeader>
				<silk:TableBody>
					<silk:Column align="center" ordering="true" width="40px" />
					<silk:Column width="325px" >{selectName}</silk:Column>
					<silk:Column align="right" ><i class="fas fa-chevron-circle-right"></i></silk:Column>
				</silk:TableBody>
			</silk:Table>
			
			<!--  Operation -->
			<br/>
			<silk:Table id="operationList" dataSource="operationDP" title="Operations" targetPage="operationFormPage" header="none"
				cssClass="table-sm xno-border" autoSelect="false" searchable="true"
			>
				<silk:TableHeader>
					<silk:Button id="operationFilterBt" icon="fa-solid fa-magnifying-glass" cssClass="btn-secondary btn-sm" dock="right" cssStyle="padding:0px 2px" />
					<silk:Button id="operationAddBt" icon="fas fa-plus" cssClass="btn-primary btn-sm" dock="right" cssStyle="padding:0px 2px" renderIf="${editRight}" />
				</silk:TableHeader>
				<silk:TableBody>
					<silk:Column align="center" ordering="true" width="40px" />
					<silk:Column width="325px" renderer="operationNameRenderer" >{type}</silk:Column>
					<silk:Column align="right" ><i class="fas fa-chevron-circle-right"></i></silk:Column>
				</silk:TableBody>
			</silk:Table>

			<box id="databaseExtra" >
				<br/>
				<silk:Table id="authorizationList" dataSource="authorizationDP" title="Authorization" targetPage="authorizationFormPage" header="none" cssClass="table-sm xno-border" autoSelect="false" >
					<silk:TableHeader>
						<silk:Button id="authorizationAddBt" icon="fas fa-plus" cssClass="btn-primary btn-sm" dock="right" cssStyle="padding:0px 2px" renderIf="${editRight}" />
					</silk:TableHeader>
					<silk:TableBody>
						<silk:Column align="center" ordering="true" width="40px" />
						<silk:Column width="325px" >{authorizationName}</silk:Column>
						<silk:Column align="right" ><i class="fas fa-chevron-circle-right"></i></silk:Column>
					</silk:TableBody>
				</silk:Table>
				
				<!--  FK List -->
				<br/>
				<silk:Table id="fkList" dataSource="fkDP" title="Referential Columns" targetPage="fkFormPage" header="inline" cssClass="table-sm xno-border" autoSelect="false" >
					<silk:TableHeader>
						<silk:Button id="fkAddBt" icon="fas fa-plus" cssClass="btn-primary btn-sm" dock="right" cssStyle="padding:0px 2px" renderIf="${editRight}" />
					</silk:TableHeader>
					<silk:TableBody>
						<silk:Column title="<i class='fas fa-sort'></i>" align="center" ordering="true" width="50px" />
						<silk:Column title="Name" >{columnName}</silk:Column>
						<silk:Column title="Type" renderer="renderType" >{type}</silk:Column>
						<silk:Column title="Key" renderer="renderPK" >{pk}</silk:Column>
					</silk:TableBody>
				</silk:Table>
				<br/>
			</box>
			
			<br/>

		</silk:Content>
	</silk:Page>

	<silk:Modal id="extractColumnModal" title="Columns Code" >
		<silk:Tab id="extractColumnTab">
			<silk:TabItem title="List" ></silk:TabItem>
			<silk:TabItem title="Double" ></silk:TabItem>
			<silk:TabItem title="Inputs" ></silk:TabItem>
		</silk:Tab>
	</silk:Modal>
	
	<silk:DataProvider id="queryTypeDP" pkColumn="queryTypeID" >
		{"queryTypeID":"SQL", "queryTypeLabel":"Database"},
		{"queryTypeID":"Folder", "queryTypeLabel":"File System"}
	</silk:DataProvider>
	
	<silk:JScode>

		var operationNameRenderer = function(index,item,data){
			if( data=="exec") return item.operationName;
			return "Trigger: "+item.whenLabel+" "+item.actionLabel;
		}
		
	</silk:JScode>

	<silk:JQcode>

		xmlCode.codeEditor.setDarkTheme();
		xmlCode.$dataField.attr("class","");
		xmlCode.$dataField.parent().attr("class","");
		xmlCode.$dataField.parent().css("margin","0");
		
		createCode.codeEditor.setDarkTheme();
		createCode.$dataField.attr("class","");
		createCode.$dataField.parent().attr("class","");
		createCode.$dataField.parent().css("margin","0");
	
		queryForm.queryType.on("change", function(){
			ormObject.queryType = queryForm.queryType.getValue();
			onQueryTypeChange();
		});
		
		onQueryTypeChange = function(){

			$("#databaseExtra").toggle(queryForm.queryType.getValue()=='SQL'); //Authorization and Referential Columns
			$("#sqlViewBt").toggle(queryForm.queryType.getValue()=='SQL');
			
			/*
			 * Table Page
			 */
			tableForm.setInputMode(tableForm.getMode());
			$("#tableDBTab").toggle(queryForm.queryType.getValue()=='SQL');
			$("#tableDBTab_content").toggle(queryForm.queryType.getValue()=='SQL')
		
			/*
			 * Table Page
			 */
			columnForm.setInputMode(columnForm.getMode());
			$("#typeTab").toggle(queryForm.queryType.getValue()=='SQL');
			$("#typeTab_content").toggle(queryForm.queryType.getValue()=='SQL');
			$("#columnDatabase_tab").toggle(queryForm.queryType.getValue()=='SQL');
		}
		
	</silk:JQcode>

	<silk:JQcode>
		unselectList = function(list){
			if (list==undefined) list="";
			$(".silk-table").each(function(index,element){
				var listID = $(element).attr("id");
				if( listID!=list) window[listID].unselectRow();
			});
		}
	</silk:JQcode>

	<silk:JQcode>
		extractColumnBt.on("click", function(){
			extractColumnModal.show();
			
			let xml = "";
			let list = "";
			let double = "";
			for( x=0; x<columnDP.size(); x++){
				let item = columnDP.getItemAt(x);
				xml += escapeHtml("<"+"silk:Input id=\""+item.columnName+"\" type=\"\" label=\""+item.columnName+"\" />")+"<br>";
				list += item.columnName+"<br>";
				double += item.columnName+" "+item.columnName+"<br>";
			}
			extractColumnTab.getTabs(0).$content.html(list);
			extractColumnTab.getTabs(1).$content.html(double);
			extractColumnTab.getTabs(2).$content.html(xml);
			
		});
	</silk:JQcode>
	
</silk:Module>