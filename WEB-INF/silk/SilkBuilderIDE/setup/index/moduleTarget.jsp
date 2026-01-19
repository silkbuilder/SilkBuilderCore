<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="targetListPage" stage="B1" returnPage="systemListPage"
		smLayout="B1:*:b"
		mdLayout="B1:*:b"
		rgLayout="A1:600px,B1"
		lgLayout="A1:600px,B1"
		xlLayout="A1:600px,B1"
		xxLayout="A1:600px,B1"
	>
		<silk:Header >
			Target Hosts
		</silk:Header>
		<silk:Content>
			<silk:Table id="targetList" dataSource="targetDP" parentList="" >
				<silk:Column title="Host URL" >{targetURL}</silk:Column>
				<silk:Column width="20px" align="right" more="true" targetPage="targetFormPage" renderIf="${developerRole} in admin, architect" />
			</silk:Table>
		</silk:Content>
	</silk:Page>
	
	<silk:Page id="targetFormPage" stage="B2" renderIf="${developerRole} in admin, architect"
		smLayout="B2:*:b"
		mdLayout="B2:*:b"
		rgLayout="A1:600px,B2:*:b"
		lgLayout="A1:600px,B2:*:b"
		xlLayout="A1:600px,B2:*:b"
		xxLayout="A1:600px,B2:*:b"
	>
		<silk:Header >
			System
		</silk:Header>
		<silk:Content>
		
			<silk:Form id="targetForm" dataSource="targetList" buttonTarget="targetListPage,targetFormPage" >
				<silk:Input id="targetURL" type="text" label="Host URL" required="true" />
				<silk:Input id="langList" type="options" label="Languages" dataSource="langDP"
					valueColumn="langID" labelColumn="enName"
					description="English is used as default if not language is selected."
				/>
				<silk:Input id="defaultLangID" type="select" label="Default Language" dataSource="langDP"
					valueColumn="langID" labelColumn="enName"
				/>
				<silk:Input id="accessToken" type="text" label="Access Token" />
				<silk:Input id="targetdb" type="text" label="Target {db}" maxLength="50" hideEmpty="true" />
				<silk:Input id="targetdb1" type="text" label="Target {db1}" maxLength="50" hideEmpty="true" />
				<silk:Input id="targetdb2" type="text" label="Target {db2}" maxLength="50" hideEmpty="true" />
				<silk:Input id="targetdb3" type="text" label="Target {db3}" maxLength="50" hideEmpty="true" />
				<silk:Input id="targetdb4" type="text" label="Target {db4}" maxLength="50" hideEmpty="true" />

				<silk:Input id="silkSystemID" value="(silkSystemID)" />
				<silk:Input id="silkTargetID" />
			</silk:Form>
		
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="targetDP" servicePath="/SilkBuilderIDE/setup/TargetOutlet" selectName="targetList" autoLoad="false" />

	<silk:JQcode>
		
		targetDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID",systemDP.getPKValue());
		});
		
	</silk:JQcode>
	
</silk:Module>
