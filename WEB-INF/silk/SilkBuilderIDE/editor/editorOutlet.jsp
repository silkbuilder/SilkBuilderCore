<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.oopsclick.silk.dbo.*,java.io.*" %>

<jsp:include page="../system/checkRights.jsp" flush="true" >
	<jsp:param name="writeRoles" value="admin,architect" />
</jsp:include>

<silk:App title="Outlet Editor" timeout="false" >
	
	<silk:Screen>
		
		<silk:Page id="outletPage" stage="A"
			smLayout="A"
			mdLayout="A"
			rgLayout="A"
			lgLayout="A"
			xlLayout="A"
			xxLayout="A"
		>
			<silk:Header>
				Outlet Editor.
			</silk:Header>
			<silk:Content>
				<silk:Form id="outletForm" dataSource="outletDP" buttonTarget="none,outletPage,none" buttonTest="${editRight}" >
					
					<silk:Input id="projectPath" type="button" label="Target ORM" targetPage="ormModal" />
					<silk:Input id="silkProjectID" type="hidden" />
					<silk:Input id="ormPath" type="hidden" />
					
					<silk:Input id="directCalls" type="checkbox" label="Accepts direct calls. Uses select called default."
						visible="outletForm.getAction()=='update' || outletForm.directCalls.getValue()==1"
						toggleList="executeBt"
					/>

					 <silk:Input id="parameter" type="text" label="Direct access parameter"
						 visible="outletForm.getAction()=='update' ? ( outletForm.directCalls.getValue()==1 ) : outletForm.parameter.getValue()!='' "
					 />

					<silk:Input id="directCallData" type="checkbox" label="Returns metadata on direct call"
						visible="outletForm.getAction()=='update' ? ( outletForm.directCalls.getValue()==1 ) : outletForm.directCallData.getValue()==1"
					/>
					
					<silk:Input id="accessRights" type="options" label="Access Rights"
						dataSource="accessDP" valueColumn="value"
						itemsDirection="horizonal"
						visible="outletForm.getAction()=='update' || outletForm.accessRights.getValue()!=''"
						description="No selection grants full access."
					/>

					<silk:Input id="columnList" type="options" label="Columns" dataSource="columnDP"
						valueColumn="columnName" labelColumn="columnName"
						itemsDirection="horizonal"
						visible="outletForm.getAction()=='update' || outletForm.columnList.getValue()!=''"
						description="No selection grants access to all columns."
					 />
					
					<silk:Input id="selectList" type="options" label="Selects" dataSource="selectDP"
						valueColumn="selectName"
						labelColumn="selectName"
						visible="outletForm.getAction()=='update' || selectDP.size()>0"
						description="No selection grants access to all selects."
					 />

					 <silk:Input id="operationList" type="options" label="Operations" dataSource="operationDP"
						valueColumn="operationName"
						labelColumn="operationName"
						visible="(outletForm.getAction()=='update' || outletForm.operationList.getValue()!='') && operationDP.size()>0"
						 description="No selection grants access to all operations."
					 />
					
				</silk:Form>
			</silk:Content>		
		</silk:Page>
		
		<silk:Modal id="ormModal" title="Select ORM" >
			<silk:ModalBody>
				<silk:Table id="ormList" dataSource="ormDP" header="none" searchable="true" autoSelect="false" >
					<silk:Column>{projectPath}</silk:Column>
					<silk:Column icon="fa-solid fa-angle-right" align="right" />
				</silk:Table>
			</silk:ModalBody>
		</silk:Modal>
		
	</silk:Screen>
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" />
	
	<silk:DataProvider id="ormDP" servicePath="/SilkBuilderIDE/system/ProjectOutlet" selectName="ormList" autoLoad="fase" />
	
	<silk:DataProvider id="outletDP" pkColumn="ormPath" />
	
	<silk:DataProvider id="ormContentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="ormContent" autoLoad="false" />

	<silk:DataProvider id="accessDP" >
		{"value":"S", "label":"Select"},
		{"value":"I", "label":"Insert"},
		{"value":"U", "label":"Update"},
		{"value":"D", "label":"Delete"}
	</silk:DataProvider>

	<silk:DataProvider id="columnDP" pkColumn="columnName" />
	
	<silk:DataProvider id="selectDP" pkColumn="selectName" />
	
	<silk:DataProvider id="operationDP" pkColumn="operationName" />
	
	<silk:JScode>
		var silkProjectID = "${urlParameter0}";
		var silkSystemID = "${urlParameter1}"
		var toSave = false;
		var item;
		var oldORM = "";
		var formAction = "none";
	</silk:JScode>
	
	<silk:JQcode>
		
		contentDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", silkProjectID );
		});
		
		contentDP.on("afterSelect", function(action){

			item = contentDP.getItem();
			outletPage.setTitle( item.projectName + " - Outlet Editor"  );

			loadOutlet();

			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
			
		});

		loadOutlet = function(){

			/*
			 * Creates an empty array is content is not JSON.
			 */
			if( item.content.substring(0,1)!="{" ) item.content = "[]";
				
			/*
			 * Parse JSON from content
			 */
			 outletDP.selectObject.data = JSON.parse("["+item.content+"]");

			outletDP.load();

			if( outletDP.getItem().ormPath.trim() == "" ){
				outletForm.setUpdate();
				ormModal.show();
			}else{
				ormContentDP.select();
			}
			
		};
		
		<silk:If renderIf="${editRight}" >
		
			outletDP.on("afterUpdate",function(){
				contentDP.setParameter("silkProjectID", silkProjectID);
				contentDP.setParameter("content", JSON.stringify(outletDP.selectObject.data[0]));
				contentDP.exec("updateContent");
			});
			
			/*
			 * Saves content into files
			 */
			contentDP.on("afterExec", function(){
				var url = "{contextPath}/service/SilkBuilderIDE/system/saveCode";
				$.ajax({
					url: url,
					data: { silkProjectID: silkProjectID },
					success: function(data) {},
					error: function() {},
					type: 'POST'
				});
			});
		
		</silk:If>
		
	</silk:JQcode>

	<silk:JQcode>
		
		ormDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
		});
		
		outletForm.on("update", function(){
			if( outletDP.getItem().ormPath.trim() == "" ){
				/*
				 * If the ormPath is empty, the list of ORMs is loaded to select one.
				 */
				ormModal.show();
			}else{
				/*
				 * The update Button action will be canceled. The update process will be initiated after the ormContentDP is selected.
				 * This is to load any changes happening in the ORM after the outlet has been opened.
				 */
				ormContentDP.select();
				formAction = "update";
				return false;
			}
		});
		
		outletForm.on("modeChange", function(){
			toSave = outletForm.getMode();
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
	
		ormModal.on("beforeShow", function(){
			ormList.clearSearchText()			
			ormDP.select();
			$("#ormModal_closeBt").toggle(outletForm.projectPath.getValue()!="");
		});

		ormList.on("click", function(){
			outletForm.projectPath.setValue( ormList.getSelectedItem().projectPath );
			outletForm.ormPath.setValue( ormList.getSelectedItem().ormPath );
			ormContentDP.select();
			ormModal.close();
		});
		
	</silk:JQcode>
		
	<silk:JQcode>
	
		ormContentDP.on("beforeSelect", function(){
			this.setParameter("ormPath", outletForm.ormPath.getValue() );
		});
		
		ormContentDP.on("afterSelect", function(){
			let ormObject = JSON.parse(ormContentDP.getItem().content);
			
			/*
			 * Loading Columns
			 */
			let columnArray = new Array();
			for(x in ormObject.column){
				let columnItem = ormObject.column[x];
				let object = new Object();
				object["columnName"] = columnItem.columnName;
				columnArray.push(object);
			}
			columnDP.selectObject.data = columnArray;
			columnDP.select();

			/*
			 * Loading Select
			 */
			let selectArray = new Array();
			for(x in ormObject.select){
				let selectItem = ormObject.select[x];
				let object = new Object();
				object["selectName"] = selectItem.selectName;
				selectArray.push(object);
			}
			selectDP.selectObject.data = selectArray;
			selectDP.load();

			/*
			 * Loading Operations
			 */
			let operationArray = new Array();
			for(x in ormObject.operation){
				let operationItem = ormObject.operation[x];
				let object = new Object();
				object["operationName"] = operationItem.operationName;
				operationArray.push(object);
			}
			operationDP.selectObject.data = operationArray;
			operationDP.load();

			outletForm.load();

			if( formAction == "update" ){
				formAction = "none";
				outletForm.setUpdate();
			}
			
		});
		
	</silk:JQcode>
			
	<silk:JQcode>
		
		getJspCode = function(){
			
			let code = ""+
				"<"+"%\n"+
					"\tresponse.setCharacterEncoding(\"UTF-8\");\n"+
					"\tresponse.setContentType(\"application/json\");\n"+
				"%>\n"+				
				"<"+"jsp:include page=\"../../../silk/service/view/dataProvider.jsp\" >\n";
			
			code += getJspParameter("ormPath");
			code += getJspParameter("directCalls");
			code += getJspParameter("directCallData");
			code += getJspParameter("accessRights");
			code += getJspParameter("columnList");
			code += getJspParameter("selectList");
			code += getJspParameter("parameter");
			code += getJspParameter("operationList");
			
			code += "<"+"/jsp:include>";
			
			return code;
			
		};
		
		getJspParameter = function(column){
			const value = outletForm[column].getValue();
			if( value=="" ) return "";
			return "\t<"+"jsp:param name=\""+column+"\" value=\""+value+"\" />\n";
		}
		
	</silk:JQcode>

</silk:App>
