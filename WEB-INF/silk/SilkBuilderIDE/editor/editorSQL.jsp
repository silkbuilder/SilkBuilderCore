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

<silk:App title="SQL Code Editor" timeout="false" >

	<style>

		#editorBar {
			padding: 0px !important;
		}
	
		#editorBar button {
			padding: 1px !important;
		}

		#editorBar button:hover {
			text-decoration: none;
		}
	
		.container-fluid {
			padding: 3px 5px 3px 10px;
		}
	
		.title {
			float: left;
			font-weight: 400;
			font-size: 1em;
		}
		
		.silk-input-code {
			padding: 0px !important;
			margin: 0px 10px;
		}

		#selectForm {
			margin-top: 95px;
		}

		#editBt, #docBt {
			font-size: 1.3em;
		}

		#cancelBt, #submitBt {
			border-color: white;
		}

		#selectSQLTab {
			padding-top: 5px;
			background-color: var(--bs-dark);
		}
		
	</style>

	<style>
		#closeBt {
			border: 1px solid gray;
			padding: 4px;
			float: right;
		}
		
		#closeBt .silk-button-label {
			font-size: 1.2em;
		}
	</style>
	
	<script src="{contextPath}/silk/codeEditor/sqleditor.js?a=1"></script>

	<div id="topBox" class="fixed-top bg-body-tertiary" >
		<nav id="editorBar" class="navbar" >
			<div class="container-fluid silk-header-bg" >
				<div class="title">
					<i class="fa-solid fa-file"></i>
					<span id="editorTitle" ></span>&nbsp;&nbsp;|&nbsp;&nbsp;Testing Database: <span id="testingLabel" ></span>
				</div>
				<div>
					<silk:Button id="docBt" icon="fa-regular fa-file-lines" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF" targetPage="docModal" renderIf="${editRight}" />
					<silk:Button id="editBt" icon="update" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF" renderIf="${editRight}" />
					<silk:Button id="cancelBt" icon="cancel" label="Cancel" cssClass="btn-danger" dock="right" />
					<silk:Button id="submitBt" icon="submit" label="Submit" cssClass="btn-success" dock="right" />
				</div>
			</div>
		</nav>
	</div>
	
	<silk:Form id="selectForm" dataSource="selectDP" updateBt="editBt"
		cancelBt="cancelBt" submitBt="submitBt" toggleEdit="docBt"
	>
		
		<silk:Tab id="selectSQLTab">
<%
			boolean editRight = (""+request.getAttribute("editRight")).equals("true");
			String[] databaseList = (""+request.getAttribute("databaseList")).split(",");
			for( String database : databaseList){
				if( database.equals("") ) continue;
				String[] parts = database.split("\\|");
				String tabItemID = "selectSQLTab"+parts[0];
				String databaseName = parts[1];
				if( editRight ) databaseName += "&nbsp;&nbsp;<i class='fa-solid fa-copy copy-sql' ></i>";
				String sqlID = "sql"+parts[0];
%>
					
				<silk:TabItem id="<%=tabItemID%>" title="<%=databaseName%>">
					<silk:Input id="<%= sqlID %>" type="sql" mode="true" />
				</silk:TabItem>
				<silk:JQcode>
					selectForm.<%= sqlID %>.codeEditor.setDarkTheme();
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
					
<%		} %>
		</silk:Tab>

		<p style="padding:10px; margin-bottom: 4px;" >
			<silk:Input id="description" type="html" label="Description" height="100px" />
		</p>
		
	</silk:Form>
	
	<silk:Modal id="docModal" size="full" bodyMargin="false" >
		<silk:ModalBody>
			<silk:Input id="docField" type="html" mode="true" />
			<silk:Button id="closeBt" label="Close" />
		</silk:ModalBody>
	</silk:Modal>

	<silk:Modal id="copySelectModal" title="Copy select code from..." >		
	</silk:Modal>

	<silk:DataProvider id="databaseDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="targetDatabaseList" loadingOrder="1" />
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" loadingOrder="2" />
	<silk:DataProvider id="selectDP" />
	
	<silk:JScode>
		var toSave = false;
		var databaseID = 1;
		var silkProjectID = "${urlParameter0}";
		var silkSystemID = "${urlParameter1}";
	</silk:JScode>
	
	<silk:JQcode>
		
		$("#topBox").append(selectSQLTab.$tab);
		
		databaseDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
		});
		
		contentDP.on("beforeLoad", function(){
			this.setParameter("silkProjectID", silkProjectID );
		});
		
		contentDP.on("afterSelect", function(action){
			
			/*
			 * Set project path
			 */
			projectPath = contentDP.getItem().projectPath;
			projectPath = replaceAll(projectPath,"//","/");
			$("#editorTitle").html( projectPath );
			
			/*
			 * Parses content into selectDP and loads form
			 */
			 let item = {};
			 if( contentDP.getItem().content.trim()!="" ){
				item = JSON.parse(contentDP.getItem().content);
			}
			item["testingDB"] = contentDP.getItem().databaseName;
			selectDP.selectObject.data.push( item );
			selectDP.selectedIndex = 0;
			selectForm.load();
			$("#testingLabel").text(selectDP.getItem().testingDB);
			
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
			
		});

		selectForm.on("modeChange", function(){
			toSave = selectForm.getMode();
		});
		
		selectForm.on("submit", function(){
			let sqlObject = {};
			sqlObject["description"] = selectForm.description.getValue();
			for( x=1; x<5; x++ ){
				const editor = "sql"+x;
				if( selectForm[editor]!=undefined ){
					const sqlValue = selectForm[editor].getValue();
					if( sqlValue!="" ) sqlObject[editor] = sqlValue;
				}
			}
			contentDP.setParameter("silkProjectID", silkProjectID);
			contentDP.setParameter("content", JSON.stringify(sqlObject));
			contentDP.exec("updateContent");
		})
		
		docModal.on("show", function(){
			
			$(".cke_top").append($("#closeBt"));
			
			$("#cke_1_contents").height(docModal.$body.height());
			$("#cke_1_bottom").hide();
			
			var html = "";
			
			html += "<h1>DB Object: "+contentDP.getItem().projectName+"</h1>";

			html += "<h2>Description</h2>";
			html += selectForm.description.getValue();

			
			for( x=1; x<5; x++ ){
				const editor = "sql"+x;
				const title = $("#selectSQLTab"+x+"_tab").text();
				
				if( selectForm[editor]!=undefined ){
					const sqlValue = selectForm[editor].getValue();
					if( sqlValue!="" ){
						html += "<h2>"+title+" Code</h2>";
						html += renderCode(sqlValue.trim());
					}
				}
			}
			
			docField.setValue(html);
			
			setTimeout(function(){
				CKEDITOR.instances.docField_input.execCommand('maximize');
			}, 100);
			
		});
		
		closeBt.on("click",function(){
			CKEDITOR.instances.docField_input.execCommand('maximize');
			docModal.close();
		});
		
		docField.$input.css("margin","0px");
		docField.$input.find(".silk-input-label").remove();

		selectSQLTab.on("click", function(index, tabID, element){
			if( $(element).hasClass("copy-sql") ){
				copyForm = "selectForm";
				copyTo = getNumber(selectSQLTab.getSelectedTab().id);
				copySelectModal.show();
			};
		});
		
	</silk:JQcode>

	<silk:JScode>
		var copyForm = "";
		var copyTo = 0;
	</silk:JScode>
	
	<silk:JQcode>

		copySelectModal.$body.css("text-align","center");
		
		copySelectModal.on("beforeShow", function(){
			fillCopyModal();
			window[copyForm].setUpdate();
		});

		fillCopyModal = function(){
			let html = "";
			for( x in databaseDP.selectObject.data ){
				let databaseName = databaseDP.selectObject.data[x].databaseName;
				let silkDatabaseID = databaseDP.selectObject.data[x].silkDatabaseID;
				if( silkDatabaseID==copyTo ) continue;
				//if( tableForm.editorDatabaseID.getValue().indexOf(","+silkDatabaseID+",")==-1 ) continue;
				html += "<button class='btn btn-primary' onClick='copySelect("+silkDatabaseID+")' >"+databaseName+"</button>";
			}
			copySelectModal.$body.html( html );
		};
		
		copySelect = function(from){
			window[copyForm]["sql"+copyTo].setValue(window[copyForm]["sql"+from].getValue());
			copySelectModal.close();
		};
		
	</silk:JQcode>
	
</silk:App>
