<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%
	int levelLimit = 1;
%>
<silk:Module >
		
	<style>
		#structureListPage .silk-navbar-title {
			text-align: left;
			padding-left: 40px;
		}
	</style>
	
	<silk:Page id="structureListPage" stage="A1"
		smLayout="A1"
		mdLayout="A1"
		rgLayout="A1:300px,B1"
		lgLayout="A1:400px,B1"
		xlLayout="A1:400px,B1"
		xxLayout="A1:500px,B1"
	>
		<silk:Header >
			Systems
			<silk:Button id="exitBt" icon="home" dock="left" />
			<silk:Button id="projectInfoBt" icon="fa-solid fa-circle-info" dock="right" targetPage="projectFormPage" renderIf="admin,architect one-in ${developerRole}" />
		</silk:Header>
		<silk:Content>
			
			<silk:Table id="projectList" dataSource="projectDP" cssClass="table-hover no-border" targetPage="editorPage" header="none"
				collapsedLevel="<%= levelLimit %>"
				deleteBranch="true"
			>
				<silk:Column>
					<span class='{iconName}' aria-hidden='true' style='color:{iconColor};' ></span>
					{projectName}&nbsp;
					<silk:If renderIf="read!=${developerRole}" >
						<a href="javascript:void(0)" onClick="runApp('{silkProjectID}')" keepIf="('APP,PUB,CSF,CSFP,MCP').indexOf('{nodeType}')!=-1" >
							<i class="fa-solid fa-circle-play fa-lg" style="color:#C6FE3A;"></i>
						</a>
					</silk:If>
				</silk:Column>
				<silk:Column align="right" renderer="editIconCode" width="30px" ></silk:Column>
			</silk:Table>
			
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="systemDP" servicePath="/SilkBuilderIDE/system/SystemOutlet" selectName="systemLoader" loadingOrder="3" />
	<silk:DataProvider id="projectDP" servicePath="/SilkBuilderIDE/system/ProjectOutlet" selectName="projectList" treeData="true" markDeleted="true" recordSync="true" />

	<silk:JScode>
	
		var menuWindow;
		var item = {nodeType:""};
		var silkProjectID = "";
		var deletedSilkProjectID = "";
		var childrenList = [];
		
		/*
		 * Renders the edit icon
		 */
		editIconCode = function(index,item,data){
			if( item.editor>0){
				if( item.editRights==1){
					return "<span class='fa-solid fa-square-pen fa-xl' style='color:#a3b199;' ></span>&nbsp;";
				}else{
					return "<span class='fa-regular fa-circle-arrow-right fa-xl' ></span>&nbsp;";
				}
			}
			return "";
		}
				
	</silk:JScode>
	
	<silk:JQcode>
		
		structureListPage.setTitle(systemName);
	
		systemDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID",silkSystemID);
		});

		exitBt.on("click", function(){
			console.log("me");
			if( tabEditor.size()==0  ){
				window.location.href = "{contextPath}";
			}else{
				silk.confirmation(
					function(){
						window.location.href = "{contextPath}";
					},
					undefined,
					"Close Editors?",
					"Open editors to closed: "+tabEditor.size()+". Do you want to continue?",
					"Close and Exit"
				);
			}
		});

		
	</silk:JQcode>
	
	<silk:JQcode>
		
		projectDP.on("beforeSelect",function(){
			this.setParameter("silkSystemID",silkSystemID);
			<silk:If renderIf="admin in ${developerRole}" >
				this.setParameter("role","admin");
			</silk:If>
			<silk:If renderIf="architect in ${developerRole}" >
				this.setParameter("role","architect");
			</silk:If>
			<silk:If renderIf="developer in ${developerRole}" >
				this.setParameter("role","developer");
			</silk:If>
			<silk:If renderIf="read in ${developerRole}" >
				this.setParameter("role","read");
			</silk:If>
		});
		
		projectDP.on("beforeRecordSync",function(){

			silkProjectID = projectList.getSelectedItem().silkProjectID;
			if( silkProjectID.indexOf("SYS")==0 ) return false;
			
			this.setParameter("silkProjectID", silkProjectID );
			<silk:If renderIf="admin in ${developerRole}" >
				this.setParameter("role","admin");
			</silk:If>
			<silk:If renderIf="architect in ${developerRole}" >
				this.setParameter("role","architect");
			</silk:If>
			<silk:If renderIf="developer in ${developerRole}" >
				this.setParameter("role","developer");
			</silk:If>
			<silk:If renderIf="read in ${developerRole}" >
				this.setParameter("role","read");
			</silk:If>
		});

		projectDP.on("processLoadedData", function(responseObject){
			/*
			 * Adds the option menu items.
			 */
			responseObject.data = menuDP.selectObject.data.concat(responseObject.data);
			return responseObject;
		});
		

		projectDP.on("afterSelect",function(){
			/*
			 * Collapses the options folder.
			 */
			if( projectDP.getItem().silkProjectID == "SYSROOT" ){
				projectList.$table.find("td").first().trigger("click");
			}
			
		});
			
		projectDP.on("markDeleted", function(){
			projectDP.setOperationItem("status",1);
		});

		projectDP.on("afterUpdate", function(){
			/*
			 * If the branch is a project, this process is ignored.
			 */
			if( projectList.getSelectedItem().projectLevel==1 ) return;
			
			let previousName = projectForm.projectName.getPreviousValue();
			let newName = projectForm.projectName.getValue()

			let previousType = projectForm.nodeType.getPreviousValue();
			let newType = projectForm.nodeType.getValue()

			projectDP.recordSync();
			
			if( previousName!=newName || previousType!=newType ){

				$.ajax({
					url: "{contextPath}/service/SilkBuilderIDE/system/resourceRename",
					data: {
						silkProjectID: silkProjectID,
						previousName: previousName,
						previousExtension: previousExtension,
					},
					success: function(result){}
				});
				
				let frame = window.frames["frame-T"+silkProjectID];
				if( frame==undefined ) return;

				$("#T"+silkProjectID+"_tab span").text(newName);
				frame.classList.add("silk-hidden");
				frame.contentWindow.location.reload();
				
			}
			
		});

		projectForm.on("delete", function(){
			/*
			 * Saving the silkProjectID before it gets deleted and becomes inaccessible by the afterDelete trigger.
			 */
			deletedSilkProjectID = silkProjectID;
			childrenList = projectList.getChildren();
		});

		projectDP.on("afterDelete", function(){
			$.ajax({
				url: "{contextPath}/service/SilkBuilderIDE/system/resourceDelete",
				data: {
					silkProjectID: deletedSilkProjectID,
					childrenList: childrenList.toString()
				},
				success: function(result){}
			});
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
		
		projectList.on("click",function(col, index, realClick, ev){

			item = projectList.getSelectedItem();
			
			let optionMenu = projectList.getSelectedItem().optionMenu==1 ? 1:0;
			const projectLevel = projectList.getSelectedItem().projectLevel;
			const editor = ifUndefined(projectList.getSelectedItem().editor,0);

			silkProjectID = projectList.getSelectedItem().silkProjectID;
			
			/*
			 * Hides or shows the info button
			 */
			if( projectLevel==0 ) optionMenu=1;
			projectInfoBt.toggle( optionMenu==0 );
			
			<silk:If renderIf="admin, architect one-in ${developerRole}" >
				
				/*
				 * Hides or shows the insertBt
				 */
				projectForm.insertBt.toggle( item.parent==1 );

				/*
				 * Hides or shows the open sync button
				 */
				openSyncBt.toggle( item.sync==1 );

			</silk:If>
			
			/*
			 * Click in the third column to open an editor tab.
			 */
			if( col==2 && editor!=0  ){
				openTab( projectList.getSelectedItem() );
			}
		});
		
		<silk:If renderIf="developer in ${developerRole}" >
		
			/*
			 * Hides or shows the insertBt
			 */
			projectForm.on("showInsertBt", function(){
				return isIn(item.nodeType, "SRV", "APP", "CSF", "PUB", "CSFP");
			});
		
			/*
			 * Hides or shows the info button
			 */
			projectForm.on("showUdatetBt", function(){
				return isIn(item.nodeType, "APP", "PUB", "CSF", "CSFP", "MOD", "EMAIL");
			});
		
			/*
			 * Hides or shows the insertBt
			 */
			projectForm.on("showDeleteBt", function(){
				return isIn(item.nodeType, "APP", "PUB", "CSF", "CSFP", "MOD", "EMAIL");
			});
		
		</silk:If>		
		
		
		/*
		 * Open the systems's menu page
		 */
		openSystemBt.on("click", function(){
			
			if( silkSystemID == undefined  ) return;

			if( systemDP.getSelectedItem().menuLink=="" ){
				silk.alert("Warning", "The Menu Link has not been set. Use the option System Setup to set this up.", "warning");
				return;
			}
	
			var url = systemDP.getSelectedItem().menuLink;
			url = url.replace(".jsp","");
			url = "{contextPath}/service"+url+"?silkSystemID="+silkSystemID;
			localStorage.setItem("__silkSystemMenuLink", url);
			
			var openWindowMenu = false;
			
			if( menuWindow ){
				if( menuWindow.location.href== "about:blank" ){
					openWindowMenu= true;
				}

				if( menuWindow.closed ){
					openWindowMenu= true;
				}
				
			}else{
				openWindowMenu = true;
			}
			
			if( openWindowMenu ){
				menuWindow = window.open(url, '_blank');
			}else{
				menuWindow.location.href = url;
			}
			
			menuWindow.focus();
		});
		
		
		<!--  silk:If test="1,2,3,4 one-in ${silkDevRoleID}" -->
		runApp = function(silkProjectID){
			var item = projectDP.getIndexItem(silkProjectID);
		
			var nodeType = item.nodeType;
		
			var urlType = "service/";
			
			if( nodeType=="PUB" || nodeType=="CSFP" || nodeType=="OSLP" ){
				urlType = "link/";
			}

			if( nodeType=="MCP" ){
				urlType = "mcptool/";
			}
			
			var projectPath = item.projectName;

			var parentID = item.parentID;
			projectPath = projectDP.getIndexItem(parentID).projectName+"/"+projectPath;
			
			parentID = projectDP.getIndexItem(parentID).parentID;
			projectPath = projectDP.getIndexItem(parentID).projectName+"/"+projectPath;
			
			var url = "{contextPath}/" + urlType + projectPath +"?silkSystemID="+item.silkSystemID;
			
			console.log( url );
			
			window.open(url, 'run'+item.silkProjectID);

		};
		<!--  silk:If -->
		
	</silk:JQcode>
	
</silk:Module >
