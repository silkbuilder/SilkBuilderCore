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
				<silk:Button id="executeBt" icon="fa-solid fa-circle-play" dock="right" renderIf="${editRight}" />
				<silk:Button id="reloadBt" icon="fa-solid fa-rotate-right" dock="right" renderIf="${editRight}" />
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
		
		<silk:Modal id="ormModal" title="Select ORM" closeButton="false" >
			<silk:ModalBody>
				<silk:Table id="ormList" dataSource="ormDP" header="none" >
					<silk:Column>{projectPath}</silk:Column>
				</silk:Table>
			</silk:ModalBody>
			<silk:ModalFooter>
				 <button id="ormCloseBt" type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
				<silk:Button id="ormSelectBt" label="Select ORM" />
			</silk:ModalFooter>
		</silk:Modal>
		
	</silk:Screen>
	
	<silk:DataProvider id="ormDP" servicePath="/SilkBuilderIDE/system/ProjectOutlet" selectName="ormList" loadingOrder="1" />
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" loadingOrder="2" />
	<silk:DataProvider id="outletDP" pkColumn="ormPath" />
	
	<silk:DataProvider id="ormContentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" autoLoad="false" />

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
		var reload = false;
	</silk:JScode>
	
	<silk:JQcode>
		
		ormDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
		});
		
		executeBt.on("click", function(){
			window.parent.runApp(silkProjectID);
		});		

		outletForm.on("modeChange", function(){
			toSave = outletForm.getMode();
		});
		
	</silk:JQcode>
		
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

			if( item.content.substring(0,1)!="{" ){

				/*
				 * Deprecated: Parsing old outlets
				 */
				 
				var ormPath = "";
				var selectList = "";
				var parameter = "";
				var lineArray = item.content.split("\n");
				
				for(x in lineArray){
					var line = lineArray[x];
					var partArray = line.split(":");
					if( partArray[0]=="ormPath" ) ormPath = partArray[1];
					if( partArray[0]=="selectName" ) selectList = ","+partArray[1].replaceAll(" ","")+",";
					if( partArray[0]=="parameter" ) parameter = partArray[1];
				}
				
				var obj = new Object();
				oldORM = ormPath;
				obj["selectList"] = selectList;
				obj["parameter"] = parameter;
				
				outletDP.selectObject.data.push(obj);
				
			}else{
				
				/*
				 * Parse JSON from content
				 */
				 outletDP.selectObject.data = JSON.parse("["+item.content+"]");
			}
			
			//console.log( outletDP.selectObject.data );
			
			outletDP.load();
			
			<silk:If renderIf="${editRight}" >
				if( outletForm.projectPath.getValue()=="" ){
					outletForm.setUpdate();
					ormModal.show();
				}else{
					ormContentDP.load();
				}
			</silk:If>
			
			if( oldORM!="" ) outletForm.projectPath.setValue(oldORM);

			//setTimeout(function(){outletForm.load();},250);
		
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
	
		ormModal.on("show", function(){
			$("#ormCloseBt").toggle(outletForm.projectPath.getValue()!="");
		});
		
		ormSelectBt.on("click",function(){
			outletForm.projectPath.setValue( ormList.getSelectedItem().projectPath );
			outletForm.silkProjectID.setValue( ormList.getSelectedItem().silkProjectID );
			outletForm.ormPath.setValue( ormList.getSelectedItem().ormPath );
			ormModal.close();
			ormContentDP.load();
		});
		
		reloadBt.on("click", function(){
			reload = true;
			ormContentDP.load();
			silk.toast("ORM Reloaded","warning")
		});
		
	</silk:JQcode>
		
	<silk:JQcode>
	
		ormContentDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", outletForm.silkProjectID.getValue() );
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
			columnDP.load();

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
			outletForm.selectList.setValue(outletDP.selectObject.data[0].selectList);

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

			if( outletForm.getMode() ){
				outletForm.setMode(true);
				outletForm.projectPath.setPreviousValue("");
			}
			
			if( reload ){
				reload = false;
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
