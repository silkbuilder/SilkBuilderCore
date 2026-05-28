<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
	<silk:Page id="projectFormPage" stage="A2"
		smLayout="A2:*:b"
		mdLayout="A2:*:b"
		rgLayout="A2:300px:b,B1"
		lgLayout="A2:400px:b,B1"
		xlLayout="A2:400px:b,B1"
		xxLayout="A2:500px:b,B1"
	>
		<silk:Header >
			Project Item
		</silk:Header>
		<silk:Content>
			
			<silk:Form id="projectForm" dataSource="projectList" buttonTarget="structureListPage,projectFormPage"
				buttonTest="admin,architect,developer one-in ${developerRole}"
				confirmTarget="delete"
				confirmTitle="Delete Element?"
				confirmMessage="This process will remove the selected element and, if existing, the children elements."
				confirmLabel="Continue?"
			>
				<silk:Input type="select" id="nodeType" label="Type" valueColumn="nodeType" labelColumn="name" prompt="Select..."
					dataSource="nodeDP" linkedColumns="iconName,iconColor,editor,saveMode,parent,editor,saveMode"
					editable="getNodeTypeEditable()"
					required="projectForm.getAction()=='insert'"
				/>
				<silk:Input type="text" id="projectName" label="Name" required="true" />
				<silk:Input type="text" id="projectUUID" label="UUID" editable="false" scope="3" />
				<silk:Input type="hidden" id="silkSystemID" value="(silkSystemID)" />
				<silk:Input type="hidden" id="silkProjectID" />
				<silk:Input type="hidden" id="editRights" value="1" scope="2" />
			</silk:Form>
			
		</silk:Content>
	</silk:Page>
	
	<silk:DataProvider id="nodeDP" servicePath="/SilkBuilderIDE/system/NodeOutlet" selectName="selectList" />
	<silk:DataProvider id="targetDP" servicePath="/SilkBuilderIDE/setup/TargetOutlet" selectName="targetList" />

	<silk:DataProvider id="rebuildDP" servicePath="/SilkBuilderIDE/system/ProjectOutlet" selectName="sync-files" autoLoad="false"
		renderIf="admin, architect one-in ${developerRole}"
	/>
	<silk:DataProvider id="rebuildMailDP" servicePath="/SilkBuilderIDE/system/ProjectOutlet" selectName="sync-email" autoLoad="false"
		renderIf="admin, architect one-in ${developerRole}"
	/>

	<silk:JScode>
		var rebuildClearID = "";
		var changeList = "APP,CSF,CSFP,PUB";
		var previousExtension = "";
	</silk:JScode>
	
	<silk:JQcode>
		
		/*
		 * Before loading the form, it loads the node type select
		 */
		projectForm.on("beforeLoad", function(){
			//projectForm.nodeType.load();
		});

		/*
		 * Before loading the form, it loads the node type select
		 */
		projectForm.on("beforeModeChange", function(){
			projectForm.nodeType.load();
			projectForm.nodeType.setValue(projectList.getSelectedItem().nodeType);
		});

		/*
		 * Action after the form mode change
		 */
		projectForm.on("afterModeChange", function(mode){
			
			/*
			 * If the form is in read-only mode, it exits
			 */
			if( !mode ) return;
			
			/*
			 * If the selected row is not the first (Options), then expand the selection for the node type. 
			 */
			if( projectForm.nodeType.$input.find("option").length > 1 && projectForm.getAction()=="insert" ){
				projectForm.nodeType.openSelect();
			}

			/*
			 * Save the previous extension to use it during renaming.
			 */
			if( projectForm.getAction()=="update" ){
				previousExtension = ifUndefined(projectForm.nodeType.getItem().extension,"");
			}
														 
		});
		
		/*
		 * Filter the note type options to show based on the parent filter column
		 */
		projectForm.nodeType.on("filterLoad", function(index, item){
			if( projectForm.getAction()=="insert" ){
				if( item.parentFilter.indexOf(projectList.getSelectedItem().nodeType)>-1 ) return true;
			}else{
				
				let nodeType = projectList.getSelectedItem().nodeType;
				let nodeList = nodeType+",";

				if( changeList.indexOf(nodeType) > -1 ) nodeList += changeList;

				if( nodeList.indexOf(item.nodeType) > -1 ) return true;
				
			}
			return false;
		});

		/*
		 * Determines when the node type should be editable.
		 */
		getNodeTypeEditable = function(){
			if( projectForm.getAction()=='insert' ) return true;
			if( projectForm.getAction()=='delete' ) return false;
			let nodeType = projectList.getSelectedItem().nodeType;
			if( changeList.indexOf(nodeType) > -1  ) return true;
			return false;
		}
		
	</silk:JQcode>

	<silk:JQcode>
		
		/*
		 * Loads the target hosts' URLs
		 */
		targetDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID",silkSystemID);
		});
		
	</silk:JQcode>
		
	
	<silk:JQcode renderIf="admin, architect one-in ${developerRole}" >

		/*
		 * Handles rebuild button.
		 */
		rebuildBt.on("click", function(){
			rebuildDP.select();
		});

		/*
		 * Call rebuild project data provider
		 */
		rebuildDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
			this.setParameter("silkProjectID", silkProjectID);
			if( projectList.getSelectedItem().projectLevel==1 ){
				rebuildClearID = silkProjectID;
			}
		});

		/*
		 * Executes Rebuild Project
		 */
		rebuildDP.on("afterSelect", function(){
			if( rebuildClearID!="" ){
				/*
				 * Remove files on project if selected level is 1:Project.
				 */
				$.ajax({
					url: "{contextPath}/service/SilkBuilderIDE/system/resourceDelete",
					data: { silkProjectID: rebuildClearID },
					success: function(data) {},
					error: function() {},
					type: 'POST',
					async: false
				});
				rebuildClearID = "";
			}

			/*
			 * Call save for each project file on selection.
			 */
			var url = "{contextPath}/service/SilkBuilderIDE/system/saveCode";
			for( x=0; x<rebuildDP.size(); x++ ){
				let silkProjectID = rebuildDP.getItemAt(x,"silkProjectID");
				$.ajax({
					url: url,
					data: { silkProjectID: silkProjectID },
					success: function(data) {},
					error: function() {},
					type: 'POST',
					async: false
				});
			}
			rebuildMailDP.select();
		});

		/*
		 * Call rebuild email data provider
		 */
		rebuildMailDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
			this.setParameter("silkProjectID", silkProjectID);
		});

		/*
		 * Call save for each email file on selection.
		 */
		rebuildMailDP.on("afterSelect", function(){

			/*
			 * Call save for each email file on selection.
			 */
			var url = "{contextPath}/service/SilkBuilderIDE/system/saveCode";
			for( x=0; x<rebuildMailDP.size(); x++ ){
				let silkProjectID = rebuildDP.getItemAt(x,"silkProjectID");
				$.ajax({
					url: url,
					data: { silkProjectID: silkProjectID },
					success: function(data) {},
					error: function() {},
					type: 'POST',
					async: false
				});
			}
			silk.alert("Finished rebuilding files.","","info");
		});
		
	</silk:JQcode>
	
</silk:Module>
