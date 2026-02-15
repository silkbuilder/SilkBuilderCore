<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="systemFormPage" stage="A1"
		smLayout="A1"
		mdLayout="A1"
		rgLayout="A1:600px,B1"
		lgLayout="A1:600px,B1"
		xlLayout="A1:600px,B1"
		xxLayout="A1:600px,B1"
	>
		<silk:Header >
			System Setup
		</silk:Header>
		<silk:Content>
			<silk:Form id="systemForm" dataSource="systemDP"
				toggleEdit="#exportBox, #removeBox"
				buttonTarget="none,systemFormPage,none"
				buttonTest="${developerRole} in admin, architect"
			>
				<silk:Input id="systemName" type="text" label="System Name" required="true" />

				<silk:Input id="silkSystemUUID" type="text" label="System UUID" editable="false" />
				
				<silk:Input id="theme" type="select" label="Theme" dataSource="themeDP"
					valueColumn="fileName" labelColumn="fileName"
				/>
				<silk:Input id="loginLink" type="button" label="Login Link" extraProperties="readonly"
					description="From the project's tree select the public application which will operate as the application's login form and click on the button below. This service is loaded when the application is loaded first time."
				/>
				<silk:Button id="loginLinkBt" label="Set Login Link" cssClass="btn-primary btn-sm" cssStyle="margin-bottom:10px;" />
				
				<silk:Input id="menuLink" type="text" label="Menu Link" extraProperties="readonly"
					description="From the project's tree select the application which will operate as the application's menu and click on the button below. This service is loaded after the user's authentication."
				/>
				<silk:Button id="menuLinkBt" label="Set Menu Link" cssClass="btn-primary btn-sm" cssStyle="margin-bottom:10px;" />
				
				<silk:Input id="databaseList" type="options" label="Target Database" required="true"
					dataSource="databaseDP"
					valueColumn="silkDatabaseID"
					labelColumn="databaseName"
				/>

				<silk:Group title="Development Environment" >
					<silk:Input id="langList" type="options" label="Languages" dataSource="langDP"
						valueColumn="langID" labelColumn="enName"
						description="English is used as default if not language is selected."
					/>
					<silk:Input id="silkDatabaseID" type="select" label="Database" dataSource="databaseDP" prompt="Select..." required="true"
						valueColumn="silkDatabaseID" labelColumn="databaseName"
					/>
					<silk:Input id="testController" type="text" label="Controller" maxLength="50" hideEmpty="true" />
					<silk:Input id="testdb" type="text" label="Test {db}" maxLength="50" hideEmpty="true" />
					<silk:Input id="testdb1" type="text" label="Test {db1}" maxLength="50" hideEmpty="true" />
					<silk:Input id="testdb2" type="text" label="Test {db2}" maxLength="50" hideEmpty="true" />
					<silk:Input id="testdb3" type="text" label="Test {db3}" maxLength="50" hideEmpty="true" />
					<silk:Input id="testdb4" type="text" label="Test {db4}" maxLength="50" hideEmpty="true" />
				</silk:Group>

				<silk:Input type="hidden" id="silkSystemID" />
			</silk:Form>

			<div id="removeBox" class="p-2" style="display: inline-block;" >
				<hr/>
				<silk:Group title="System Removal" />
				<p>
					By checking the box below, you agree that this system will be removed from the SilkBuilder environment, and that this action cannot be undone.
					<silk:Input id="removeConfirmation" type="checkbox" label="I agree with the system's removal." mode="true" />
				</p>
				<silk:Button id="removeBt" label="Remove System" dock="right" cssClass="btn-danger btn-sm"
					confirmTitle="Remove"
					confirmMessage="The system will be removed. Do you want to continue with this operation?"
					confirmLabel="Remove"
				/>
			</div>
			<iframe id="processFrame" class="silk-hidden" ></iframe>

			<p>&nbsp</p>
			
		</silk:Content>
	</silk:Page>
	
	<silk:DataProvider id="langDP" servicePath="/SilkBuilderIDE/system/LangOutlet" loadingOrder="1" pkColumn="langID" />
	<silk:DataProvider id="databaseDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="databaseList" loadingOrder="2" />
	<silk:DataProvider id="systemDP" servicePath="/SilkBuilderIDE/system/SystemOutlet" selectName="systemLoader" loadingOrder="3" />
	<silk:DataProvider id="themeDP" servicePath="/SilkBuilderIDE/theme/ThemeOutlet" selectName="themeSelection" pkColumn="fileName" autoLoad="false" />

	<silk:JQcode>
		
		systemDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
		});		
		
		systemDP.on("afterSelect", function(){
			themeDP.select();
			targetDP.select();
		});
		
		systemDP.on("afterUpdate", function(){
			parent.langDP.select();
		});
		
		/*
		 * Show editor after being loaded.
		 */
		$(window.frameElement).removeClass("silk-hidden");
		
	</silk:JQcode>
	
	<silk:JQcode>
		
		themeDP.on("beforeSelect",function(){
			this.setParameter("silkSystemUUID", systemDP.getSelectedItem().silkSystemUUID);
		});
		
		themeDP.on("processLoadedData", function(returnObject){
			var themeList = new Array();
			for( x in returnObject.data){
				if( returnObject.data[x].fileName=="default" ){
					themeList.unshift( returnObject.data[x] );
				}else{
					themeList.push( returnObject.data[x] );
				}
			}
			returnObject.data = themeList;
			
			return returnObject;
		});
		
		themeDP.on("afterSelect", function(){
			systemForm.silkDatabaseID.load();
			systemForm.load();
		});
		
	</silk:JQcode>
	
	<silk:JQcode>

		systemForm.databaseList.on("change",function(){
			systemForm.silkDatabaseID.load();
		});

		systemForm.silkDatabaseID.on("filterLoad", function(item){
			return systemForm.databaseList.getValue().indexOf( ","+item.silkDatabaseID+"," ) > -1;
		});
		
		systemForm.on("beforeModeChange", function(mode){
			loginLinkBt.toggle(mode);
			menuLinkBt.toggle(mode);
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
		
		loginLinkBt.on("click", function(){
			if( parent.projectList.getSelectedItem().nodeType!= 'PUB' ){
				silk.alert("Warning","The selected node is not a public application.");
				return;
			}
			systemForm.loginLink.setValue( getAppLink(parent.projectList.getSelectedItem().silkProjectID)+".srv" );
		})
		
		menuLinkBt.on("click", function(){
			if( parent.projectList.getSelectedItem().nodeType!= 'APP' ){
				silk.alert("Warning","The selected node is not an application.");
				return;
			}
			systemForm.menuLink.setValue( getAppLink(parent.projectList.getSelectedItem().silkProjectID)+".jsp" );
		})
		
		getAppLink = function(id){
			var appLink = parent.projectDP.getIndexItem(id).projectName;
			var parentID = parent.projectDP.getIndexItem(id).parentID;
			appLink = parent.projectDP.getIndexItem(parentID).projectName+"/"+appLink;
			parentID = parent.projectDP.getIndexItem(parentID).parentID;
			appLink = "/"+parent.projectDP.getIndexItem(parentID).projectName+"/"+appLink;
			console.log(appLink);
			return appLink;
		}
		
	</silk:JQcode>

	<silk:JQcode desc="Remove button actions">
		
		removeBt.on("beforeClick", function(){
			if( removeConfirmation.getValue()==0 ){
				silk.alert("Warning","Check the agreement box","warning");
				return false;
			}
		});

		removeBt.on("click", function(){
			let url = "{contextPath}/service/SilkBuilderIDE/setup/removeSystem/"+silkSystemID;
			parent.location.href = url+"?"+(new Date()).getTime();
		});
		
	</silk:JQcode>			
	
</silk:Module>
