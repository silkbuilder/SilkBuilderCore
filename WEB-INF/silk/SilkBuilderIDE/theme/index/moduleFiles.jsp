<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
	<silk:Page id="filesListPage" stage="B1"
		smLayout="B1:*:b"
		mdLayout="B1:*:b"
		rgLayout="A1:300px,B1:300px,C1"
		lgLayout="A1:300px,B1:300px,C1"
		xlLayout="A1:300px,B1:300px,C1"
		xxLayout="A1:300px,B1:300px,C1"
	>
		<silk:Header>
			Files
			<silk:Button id="openEditorBt" icon="update" dock="right" />
		</silk:Header>
		<silk:Content>
			<silk:Table id="filesList" dataSource="filesDP" header="none" parentList="themeList" >
				<silk:Column>{fileName}</silk:Column>
			</silk:Table>
		</silk:Content>
	</silk:Page>
	
	<silk:DataProvider id="filesDP" servicePath="/SilkBuilderIDE/theme/ThemeOutlet" selectName="themeFiles" autoLoad="false" />
	
	<silk:JQcode>
	
		filesDP.on("beforeSelect", function(){
			
			let fileName = themeList.getSelectedItem().fileName;
			if( themeList.getSelectedItem().root==1 ) fileName="..";

			console.log(fileName,silkSystemUUID);
			
			this.setParameter("themeName", fileName );
			this.setParameter("silkSystemUUID",silkSystemUUID);
			
		});
	
	</silk:JQcode>
	
</silk:Module>