<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<style>
		#langID {
			margin: 0px 10px 0px 0px !important;
		}
	</style>

	<silk:Page id="itemListPage" stage="B1"
		smLayout="B1:*:b"
		mdLayout="B1:*:b"
		rgLayout="A1:400px,B1"
		lgLayout="A1:400px,B1"
		xlLayout="A1:400px,B1"
		xxLayout="A1:400px,B1"
	>
		<silk:Header >
			Variable Items
		</silk:Header>
		<silk:Content>
			<silk:Table id="itemList" dataSource="itemDP" parentList="groupList" >
				<silk:Column ordering="true" />
				<silk:Column title="Value" width="50px" >{tagIntValue}</silk:Column>
				<silk:Column title="English" >{content_en}</silk:Column>
				<silk:Column title="Translation" >{content}</silk:Column>
				<silk:Column title="Key" >{tagName}</silk:Column>
			</silk:Table>
			<silk:Input type="select" id="langID" dataSource="langDP"
				labelColumn="langName" valueColumn="langID" mode="true"
			/>
		</silk:Content>
	</silk:Page>
	
	<silk:Page id="itemFormPage" stage="B2"
		smLayout="B2:*:b"
		mdLayout="B2:*:b"
		rgLayout="A1:400px,B2:*:b"
		lgLayout="A1:400px,B2:*:b"
		xlLayout="A1:400px,B2:*:b"
		xxLayout="A1:400px,B2:*:b"
	>
		<silk:Header cssClass="bg-dark" >
			Item
		</silk:Header>
		<silk:Content>
			<silk:Form id="itemForm" dataSource="itemList" buttonTarget="itemListPage,itemListPage" >
				<silk:Input id="tagIntValue" type="integer" label="Value" width="50px" required="true" />
				<silk:Input id="content" type="text" label="Label" width="350px" required="true" />
				<silk:Input id="tagName" type="text" label="Key" width="200px" />
				<silk:Input id="silkSystemID" type="hidden" value="(silkSystemID)" />
				<silk:Input id="parentID" type="hidden" value="groupList.getSelectedItem('silkTagID')" />
				<silk:Input id="tagLevel" type="hidden" value="2" />
				<silk:Input id="tagType" type="hidden" value="1" />
				<silk:Input id="silkTagID" type="hidden" />
			</silk:Form>
		</silk:Content>
	</silk:Page>	

	<silk:DataProvider id="itemDP" servicePath="/SilkBuilderIDE/system/TagOutlet" selectName="variableItem" autoLoad="false" />

	<silk:JQcode>
		
		itemDP.on("beforeSelect", function(){
			this.langID = langID.getValue();
			this.setParameter("silkSystemID", silkSystemID);
			this.setParameter("targetLangID",langID.getValue());
			this.setParameter("silkTagID", groupList.getSelectedItem("silkTagID"));
			itemListPage.setTitle("Variable - "+groupList.getSelectedItem().tagName);
		});
		
		itemDP.on("beforeLoad", function(){
			this.setLangID(langID.getValue());
		});
		
		itemForm.tagIntValue.on("modeChange", function(){
			if( itemForm.tagIntValue.getValue()=="" && itemDP.size()==0 ) itemForm.tagIntValue.setValue("0");
		});
		
		itemForm.on("showInsertBt",function(){
			return langID.getValue()=="en" && groupDP.size()>0;
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
	
		itemListPage.$page.find('.silk-navbar-right').prepend($("#langID"));
		langID.$dataField.addClass("form-control-sm");
		langID.$input.css("width","200px")
		
		langDP.on("beforeLoad", function(){
			langDP.setParameter("silkSystemID", silkSystemID );
		});
			
		langID.on("change", function(){
			groupDP.load();
		});

	</silk:JQcode>
		
</silk:Module>
