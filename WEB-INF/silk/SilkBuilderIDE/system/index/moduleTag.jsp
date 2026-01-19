<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="tagListPage" stage="C1"
		smLayout="C1:*:b"
		mdLayout="C1:*:b"
		rgLayout="B1:*:b,C1:500px"
		lgLayout="B1:*:b,C1:600px"
		xlLayout="B1:*:b,C1:700px"
		xxLayout="B1:*:b,C1:800px"
	>
		<silk:Header >
			<silk:Button id="copyTagBt" icon="fa-solid fa-turn-down fa-flip-horizontal" dock="left" />
			Translation Tags
		</silk:Header>
		<silk:Content>
			
			<silk:Tab id="tagTab" >
				<silk:TabItem title="System" />
				<silk:TabItem title="Silk" />
			</silk:Tab>
			
			<silk:Table id="tagTree" dataSource="tagDP" header="none" >
				<silk:Column >{tagName}</silk:Column>
				<silk:Column >{content}</silk:Column>
			</silk:Table>
			
			<silk:Input id="langID" type="select" dataSource="langDP" labelColumn="langName" width="200px" mode="true" />
			
		</silk:Content>
	</silk:Page>

	<silk:Page id="tagFormPage" stage="C2"
		smLayout="C2:*:b"
		mdLayout="C2:*:b"
		rgLayout="B1:*:b,C2:500px:b"
		lgLayout="B1:*:b,C2:600px:b"
		xlLayout="B1:*:b,C2:700px:b"
		xxLayout="B1:*:b,C2:800px:b"
	>
		<silk:Header cssClass="bg-dark" >
			Tag Information
		</silk:Header>
		<silk:Content>
			<silk:Form id="tagForm" dataSource="tagTree" buttonTarget="tagListPage,tagListPage" >
				
				<silk:Input id="tagName" type="text" label="Tag Name" required="true" description="Lower case with dash." />
				
				<silk:Input id="contentType" type="select" label="Content Type" dataSource="contentTypeDP" width="200px"
					visible="tagForm.folderOnly.getValue()==0"
				/>
				<silk:Input id="folderOnly" type="checkbox" label="Folder Only" width="200px" />
				
				<silk:Input id="content" type="hidden" />
				
				<silk:Input id="content0" type="text" label="Content" scope="3"
					visible="tagForm.contentType.getValue()==0"
				/>
				<silk:Input id="content1" type="textarea" label="Content" scope="3" height="500px"
					visible="tagForm.contentType.getValue()==1"
				/>
				<silk:Input id="content2" type="html" label="Content" scope="3"
					visible="tagForm.contentType.getValue()==2"
				/>

				<silk:Input type="hidden" id="silkSystemID" value="(tagSystemID)" />
				<silk:Input type="hidden" id="silkTagID" />
				
			</silk:Form>
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="tagDP" servicePath="/SilkBuilderIDE/system/TagOutlet" treeData="true" autoLoad="false" />
	<silk:DataProvider id="langDP" servicePath="/SilkBuilderIDE/system/LangOutlet" selectName="systemLang" pkColumn="langID" />
	
	<silk:DataProvider id="contentTypeDP" pkColumn="contentType" >
		{"contentType":"0", "label":"Text"},
		{"contentType":"1", "label":"Text Area"},
		{"contentType":"2", "label":"HTML"}
	</silk:DataProvider>
	
	<silk:JScode>
		var selectedText = "";
		var tagType = 0;
		var tagProjectID = "";
		var tagSystemID = 0;
	</silk:JScode>
	
	<silk:JQcode>
		
		langDP.on("beforeLoad", function(){
			this.setParameter("silkSystemID", silkSystemID );
		});
		
		tagTab.$tab.prepend( $("#langID") );
		langID.$dataField.addClass("form-control-sm");
		langID.$input.css("padding-right","10px");
		langID.$input.css("padding-left","10px");
		
		langID.on("change",function(){
			tagDP.select();
		});
		
		tagTab.on("click", function(){
			tagDP.load();
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
	
		tagDP.on("beforeLoad", function(){
			
			if( tagTab.index==0 ){
				this.setSelectName("systemTags");
				tagSystemID = silkSystemID;
			}
			
			if( tagTab.index==1 ){
				this.setSelectName("silkTags");
				tagSystemID = 0
			}
			
			this.setParameter("silkSystemID", silkSystemID );
			this.setLangID( langID.getValue() );
			
		});
		
		tagDP.on("afterInsert", function(){
			if( selectedText != "" ) copyTagBt.click(); 
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
		
		copyTagBt.on("click", function(){
			if( tagTree.getSelectedItem().silkTagID==0 ) return;
			var tag = "$T{"+tagTree.getSelectedItem().tagName+"}";
			window["frame-"+tabEditor.getSelectedTab().id].contentWindow.silkEditor.replaceSelection(tag);
			window["frame-"+tabEditor.getSelectedTab().id].contentWindow.saveBt.show();
		});
		
		tagForm.on("afterModeChange", function(mode){
			if( tagForm.getAction()=="insert" ){
				selectedText = window["frame-"+tabEditor.getSelectedTab().id].contentWindow.silkEditor.getSelection();
				tagForm.content.setValue(selectedText);
			}
			if(mode){
				tagForm.content0.setValue( tagForm.content.getValue() );
				tagForm.content1.setValue( tagForm.content.getValue() );
				tagForm.content2.setValue( tagForm.content.getValue() );
			}
		});
		
		tagForm.tagName.on("keydown",function(e){
			const key = e.key;
			if( key=="Backspace" ) return true;
			if( key=="Delete" ) return true;
			if( key=="Tab" ) return true;

			let limit = "abcdefghijklmonopqrstuvwxyz1234567890-";			
			if( limit.indexOf(key)==-1 ) return false;
		});
		
		tagForm.folderOnly.on("change",function(){
			tagForm.contentType.setValue(0);	
		});
		
		tagForm.on("showInsertBt", function(){
			if( langID.getValue()!="en" ) return false;
			if( tagTree.getSelectedItem().tagLevel>2 ) return false;
			return true;
		});
		
		tagForm.on("beforeSubmit", function(){
			if( tagForm.contentType.getValue()==0 ) tagForm.content.setValue(tagForm.content0.getValue());
			if( tagForm.contentType.getValue()==1 ) tagForm.content.setValue(tagForm.content1.getValue());
			if( tagForm.contentType.getValue()==2 ) tagForm.content.setValue(tagForm.content2.getValue());
		});
		
	</silk:JQcode>
	
</silk:Module>
