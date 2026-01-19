<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.oopsclick.silk.dbo.*" %>
<silk:App title="SilkBuilder Core" theme="builder" >

	<style>
		body {
			min-height: 100vh;
			display: grid;
			grid-template-rows: 1fr auto;
		}
		
		.top-menu h3 {
			margin:0px !important;
		}

		footer a {
			color: white;
		}

		footer a:hover {
			color: white;
		}
		
	</style>
	
 	<style>
 	
 		#systemList .card {
			max-width: 31%;
			margin: 20px;
			display: table;
		}

		.system-icon {
			position: absolute;
		 	background-color: var(--silk-header-bg);
			left: -20px;
			top: -20px;
			width: 35px;
			height: 35px;
			padding-top: 3px;
			border:2px solid #e9ecef !important;
			border-radius: 35px !important;
		}
			
 		.system-label {
	 		display: table-cell;
 			vertical-align: middle;
 			font-size: 1.1em;
 			line-height: 1.2em;
			height: 100px;
 		}
 
 	</style>
 	
  	<style>
 		.card-option {
 			margin: 5px;
 			padding: 5px;
 			width: 100px;
 			height: 100px;
 		}
 		
 		.card-icon {
	 		padding-top: 10px;
 			font-size: 1.5em;
 		}
 		
 		.card-label {
 			padding-top: 5px;
	 		line-height: 1em;
	 		font-size: 0.9em;
			height: 50px;
 		}
 		
 	</style>
	
	<main>

		<!-- Header -->
		<header>
			<div class="navbar silk-header-bg" >
				<div class="container d-flex justify-content-between">
					
					<div class="top-menu" >
						<table>
							<tr>
								<td>
									<img src="{contextPath}/resources/SilkBuilder-white.png" width="40px" />
								</td>
								<td>&nbsp;</td>
								<td>
									<h3>SilkBuilder Core</h3>
								</td>
							</tr>
						</table>
					</div>
						
					<div class="top-menu" align="right" >
						<silk:Button label="Set Password" icon="fa-solid fa-key" cssClass="btn-sm" targetPage="passwordModal" />
						<silk:Button label="Logout" icon="fas fa-lock" cssClass="btn-danger btn-sm silk-logout-button" />					
					</div>
					
				</div>
			</div>
		</header>

		<!-- Selector -->
		<div class="py-3" style="padding-top:0px;" >
			<div class="container" >
				<h4>Systems</h4>
				<silk:Tile id="systemList" dataSource="systemDP" cssClass="d-flex flex-wrap" >
					<div class="card card-option silk-header-bg" >
						<div class="system-icon" align="center" >
							<i class="fa-solid fa-screwdriver-wrench"></i>
						</div>
						<div class="system-label" align="center" >
							<div>{systemName}</div>
							<div style="font-size:0.7em;" >({creationDate|date})</div>
						</div>
					</div>
				</silk:Tile>
			</div>
		</div>
		
		<silk:If renderIf="${silkAdmin}" >
			<div id="newProjectBox" class="card card-option silk-hidden" >
				<div class="system-label" align="center">
					<div>
						<i class="fa-solid fa-plus" style="font-size:3em;" ></i>
					</div>
				</div>
			</div>
		</silk:If>
		
	</main>

	<footer class="silk-header-bg" style="text-align:center;padding:10px;" >
		<a href="https://silkBuilder.com" target="_blank" >SilkBuilder</a> |
		<a href="https://oopsclick.com" target="_blank" >OopsClick</a>
	</footer>
	
	<silk:DataProvider id="systemDP" servicePath="/SilkBuilderIDE/system/SystemOutlet" selectName="systemList" pkColumn="silkSystemID" />
	
	<silk:JQcode>
	
		systemList.on("afterLoad", function(){
			<silk:If renderIf="${silkAdmin}" >
				systemList.appendCell("newProjectBox");
			</silk:If>
		});

		systemList.on("click", function(item, $content, dpIndex, cellIndex, event){
			if( item==undefined ){
				addSystemModal.show();
			}else{
				window.location.href = "{contextPath}/service/SilkBuilderIDE/system/index/"+item.silkSystemID;
			}
		});
		
	</silk:JQcode>

	<!-- Change Password -->
	<silk:Modal id="passwordModal" title="Change Password" >
		<silk:ModalBody >
			<silk:Form id="passwordForm" submitBt="passwordSubmitBt" cancelBt="passwordCancelBt" mode="true" >
				<silk:Input id="newPassword" type="password" label="Password" required="true" />
				<silk:Input id="newPassword2" type="password" label="Repeat Password" required="true" />
			</silk:Form>			
		</silk:ModalBody>
		<silk:ModalFooter>
			<silk:Button id="passwordCancelBt" label="Cancel" cssClass="btn-danger" />
			<silk:Button id="passwordSubmitBt" label="Submit" />
		</silk:ModalFooter>
	</silk:Modal>
	
	<!-- Adding -->
	<silk:Modal id="addSystemModal" title="Add System" >
		<silk:Input id="systemName" type="text" label="System Name" mode="true" maxLength="50"
			description="A minimun of 4 characters."
			descriptionPlace="bottom"
		/>
		<silk:Input id="silkDatabaseID" type="select" label="Development Database"  prompt="Select..."
			dataSource="databaseDP" valueColumn="silkDatabaseID" labelColumn="databaseName" mode="true"
		/>
		<div align="right" >
			<silk:Button id="addSystemBt" label="Add System" disabled="true" 
				confirmTitle="Adding a new System"
				confirmMessage="Do you want to add a new system?"
				confirmLabel="Yes, add system"
			/>
		</div>
	</silk:Modal>
	
	<silk:DataProvider id="databaseDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="databaseList" />
	
	<silk:JQcode >
		
		addSystemModal.on("beforeShow", function(){

			/*
			 * Create System initialization
			 */
			systemName.setValue("");
			addSystemBt.setDisable();

		});

		addSystemModal.on("afterShow", function(){
			systemName.focus();
		});
		
	</silk:JQcode>

	<silk:JQcode >
		
		systemName.on("keyup", function(){
			addSystemBt.setEnable(systemName.getValue().length>3 && silkDatabaseID.getValue()!="" )
		});

		silkDatabaseID.on("change", function(){
			addSystemBt.setEnable(systemName.getValue().length>3 && silkDatabaseID.getValue()!="" )
		});
		
		addSystemBt.on("click", function(){
			window.location.href = "{contextPath}/service/SilkBuilderIDE/menu/addSystem"+
				"?silkDatabaseID="+silkDatabaseID.getValue()+
				"&systemName="+systemName.getValue();
		});

	</silk:JQcode>

	<silk:JQcode>

		passwordModal.on("beforeShow", function(){
			passwordForm.setMode(true);
		});

		passwordCancelBt.on("click", function(){
			passwordModal.close();
		});

		passwordForm.on("submitBtActivation", function(){
			if( passwordForm.newPassword.getValue() !== passwordForm.newPassword2.getValue() ){
				return false;
			}
		});

		passwordSubmitBt.on("click", function(){
			passwordForm.post("{contextPath}/service/SilkBuilderIDE/selector/changePassword",function(result,response){
				passwordModal.close();
				passwordForm.clean();
			});
		});
					
	</silk:JQcode>
				
</silk:App>
