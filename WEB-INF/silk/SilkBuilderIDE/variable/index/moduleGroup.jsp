<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="groupListPage" stage="A1"
		smLayout="A1"
		mdLayout="A1"
		rgLayout="A1:400px,B1"
		lgLayout="A1:400px,B1"
		xlLayout="A1:400px,B1"
		xxLayout="A1:400px,B1"
	>
		<silk:Header >
			Variable Groups
		</silk:Header>
		<silk:Content>
			<silk:Table id="groupList" dataSource="groupDP" header="none" >
				<silk:Column >{tagName}</silk:Column>
			</silk:Table>
		</silk:Content>
	</silk:Page>
	
	<silk:Page id="groupFormPage" stage="A2"
		smLayout="A2:*:b"
		mdLayout="A2:*:b"
		rgLayout="A2:400px:b,B1"
		lgLayout="A2:400px:b,B1"
		xlLayout="A2:400px:b,B1"
		xxLayout="A2:400px:b,B1"
	>
		<silk:Header cssClass="bg-dark" >
			Variable Item
		</silk:Header>
		<silk:Content>
			<silk:Form id="groupForm" dataSource="groupList" buttonTarget="groupListPage,groupListPage" >
				<silk:Input id="tagName" type="text" label="Group Tag" />
				<silk:Input id="silkSystemID" type="hidden" value="(silkSystemID)" />
				<silk:Input id="tagLevel" type="hidden" value="1" />
				<silk:Input id="tagType" type="hidden" value="1" />
				<silk:Input id="silkProjectTagID" type="hidden" />
			</silk:Form>
		</silk:Content>
	</silk:Page>	

	<silk:DataProvider id="langDP" servicePath="/SilkBuilderIDE/system/LangOutlet" selectName="systemLang" pkColumn="langID" loadingOrder="01" />
	<silk:DataProvider id="groupDP" servicePath="/SilkBuilderIDE/system/TagOutlet" selectName="variableGroup" autoLoad="false" />

	<silk:JQcode>

		langDP.on("afterSelect", function(){
			groupDP.select();
		});
		
		groupDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
		});
	
		groupDP.on("afterSelect",function(){
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
		});
		
		groupForm.tagName.on("keydown",function(e){
			const key = e.key;
			if( key=="Backspace" ) return true;
			if( key=="Delete" ) return true;
			if( key=="Tab" ) return true;
			if( key=="ArrowRight" ) return true;
			if( key=="ArrowLeft" ) return true;

			let limit = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890-";			
			if( limit.indexOf(key)==-1 ) return false;
		});
		
		
	</silk:JQcode>
		
</silk:Module>
