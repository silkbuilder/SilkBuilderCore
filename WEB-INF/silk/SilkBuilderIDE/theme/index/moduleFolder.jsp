<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
	<silk:Page id="themeListPage" stage="A1"
		smLayout="A1"
		mdLayout="A1"
		rgLayout="A1:300px,B1:300px,C1"
		lgLayout="A1:300px,B1:300px,C1"
		xlLayout="A1:300px,B1:300px,C1"
		xxLayout="A1:300px,B1:300px,C1"
	>
		<silk:Header>
			Theme List
			<silk:Button id="copyBt" icon="fa-solid fa-wrench" dock="right" targetPage="themeModal" />
		</silk:Header>
		<silk:Content>
			<silk:Table id="themeList" dataSource="themeDP" header="none" >
				<silk:Column>{fileIcon} {fileName}</silk:Column>
			</silk:Table>			
		</silk:Content>
	</silk:Page>
	
	<silk:Modal id="themeModal" title="Theme Tools" closeButton="true" >
		<silk:Group title="Rename Theme" >
			<silk:Input id="newName" type="text" placeholder="New name" mode="true" toggleList="group"
				description="All spaces will be replaced by the underecore symbol (_)."
				descriptionPlace="bottom"
			/>
			<silk:Button id="renameBt" label="Rename Theme" dock="right" />
		</silk:Group>
		<silk:Group title="Duplicate Theme" >
			<silk:Input id="duplicateName" type="text" placeholder="Theme name" mode="true"
				description="All spaces will be replaced by the underecore symbol (_)."
				descriptionPlace="bottom"
			/>
			<silk:Button id="duplicateBt" label="Duplicate Theme" />
		</silk:Group>
		<div align="right">
			<hr>
			<silk:Button id="deleteBt" label="Delete Theme" icon="delete" cssClass="btn-danger"
				confirmTitle="Theme Deletion"
				confirmMessage="The theme will be deleted. This process can't be undo."
				confirmLabel="Yes, delete."
				toggleList="parent"
			/>
		</div>
	</silk:Modal>
	
	<silk:DataProvider id="themeDP" servicePath="/SilkBuilderIDE/theme/ThemeOutlet" selectName="themeFolder" />
	
	<silk:JQcode>
		
		themeDP.on("beforeSelect",function(){
			this.setParameter("silkSystemUUID",silkSystemUUID);
		});
		
		themeDP.on("afterSelect",function(){
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
		});
		
		themeDP.on("processLoadedData", function(returnObject){
			var indexItem;
			var themeList = new Array();
			for( x in returnObject.data){

				if( returnObject.data[x].fileName=="index.html" ){
					indexItem = returnObject.data[x];
					indexItem.fileName = "Web Scaffolding";
					indexItem["root"] = 1;
					indexItem["fileIcon"] = "<i class='fa-solid fa-pen-ruler'></i>";
					continue;
				}
				
				returnObject.data[x]["fileIcon"] = "<i class='fa-solid fa-brush'></i>";
				
				if( returnObject.data[x].fileName=="default" ){
					themeList.unshift( returnObject.data[x] );
				}else{
					themeList.push( returnObject.data[x] );
				}
			}
			
			themeList.push( indexItem );
			returnObject.data = themeList;
			
			return returnObject;
		});
		
		themeDP.on("afterUpdate",function(){
			themeDP.load();
		});

		themeDP.on("afterDelete",function(){
			themeDP.load();
		});
		
		themeList.on("click",function(){
			copyBt.toggle(themeList.getSelectedItem().root!=1);
			if( themeList.getSelectedItem().root==1 ) return;
			loadSample();
		});
		
		loadSample = function(){
			var theme = themeList.getSelectedItem().fileName;
			var url = "{contextPath}/service/SilkBuilderIDE/theme/sample/"+silkSystemUUID+"/"+theme+"/?time="+(new Date()).getTime();
			$("#sampleFrame").attr("src",url);
		};
		
		themeModal.on("beforeShow",function(){
			newName.setValue("");
			newName.setVisible( themeList.getSelectedItem().fileName!="default" );
			deleteBt.toggle( themeList.getSelectedItem().fileName!="default" );
		});
		
	</silk:JQcode>
		
	<silk:JQcode>

		themeModal.on("show", function(){
			newName.setValue("");
			duplicateName.setValue("");
		});
		
		renameBt.on("click",function(){
			
			if( newName.getValue()=="" ){
				silk.alert("No Name","Add the new name in the input field.", "error");
				return;
			}
			
			if( themeExists( newName.getValue() ) ){
				silk.alert("Template Exist","The new template name already exists.", "error");
				return;
			}
			
			themeDP.setOperationItem("fileName", newName.getValue().trim().replaceAll(" ",""));
			themeDP.setOperationItem("fileID", themeList.getSelectedItem().fileID);
			themeDP.update();
			themeModal.hide();
		
		});
		
		duplicateBt.on("click",function(){
			if( duplicateName.getValue()=="" ){
				silk.alert("No Name","Add the theme name in the input field.", "error");
				return;
			}
			
			if( themeExists( duplicateName.getValue() ) ){
				silk.alert("Theme Exist","The new theme name already exists.", "error");
				return;
			}
			
			$.ajax("{contextPath}/service/SilkBuilderIDE/theme/duplicate", {
				//dataType: 'json',
				data : {
					systemUUID : silkSystemUUID,
					sourceTheme : themeList.getSelectedItem().fileName,
					targetTheme : duplicateName.getValue()
				},
				timeout: 500,
				success: function (data,status,xhr) {
					themeDP.select();
					themeModal.close();
				},
				error: function (jqXhr, textStatus, errorMessage) { // error callback 
					$('p').append('Error: ' + errorMessage);
				}
			});
			
		});
		
		deleteBt.on("click",function(){
			themeDP.setOperationItem("fileID",themeList.getSelectedItem().fileID);
			themeDP.delete();
			themeModal.close();
		});
		
		themeExists = function(name){
			for( x=0; x < themeDP.size(); x++ ){
				if( themeDP.getItemAt(x,"fileName") == name ) return true;
			}

			return false;
		}
		
	</silk:JQcode>
	
</silk:Module>

