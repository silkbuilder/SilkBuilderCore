<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="databaseListPage" stage="A1" returnPage="systemListPage"
		smLayout="A1"
		mdLayout="A1"
		rgLayout="A1:*,A2:500px"
		lgLayout="A1:*,A2:600px"
		xlLayout="A1:*,A2:700px"
		xxLayout="A1:*,A2:800px"
	>
		<silk:Header homeButton="true" >
			Databases
		</silk:Header>
		<silk:Content>
			<silk:Table id="databaseList" dataSource="databaseDP" targetPage="databaseFormPage" >
				<silk:Column title="Name" >{databaseName}</silk:Column>
				<silk:Column title="Controller" >{databaseController}</silk:Column>
			</silk:Table>
		</silk:Content>
	</silk:Page>
	
	<silk:Page id="databaseFormPage" stage="A2"
		smLayout="A2:*:b"
		mdLayout="A2:*:b"
		rgLayout="A1:*,A2:500px"
		lgLayout="A1:*,A2:600px"
		xlLayout="A1:*,A2:700px"
		xxLayout="A1:*,A2:800px"
	>
		<silk:Header >
			Database Info
		</silk:Header>
		<silk:Content>
		
			<silk:Form id="databaseForm" dataSource="databaseList" buttonTarget="null,databaseFormPage,null" >
				<silk:Input id="databaseName" type="text" label="Name" editable="false" />
				<silk:Input id="databaseController" type="text" label="Controller"
					description="Keep it emtpy to use the default database controller."
				/>
				<silk:Input id="silkDatabaseID" type="hidden"  />
			</silk:Form>
		
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="databaseDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="databaseList" />

</silk:Module>
