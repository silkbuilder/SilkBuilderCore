<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="fkFormPage" stage="G" returnPage="summaryPage"
		smLayout="G:*:b"
		mdLayout="G:*:b"
		rgLayout="A:400px,G"
		lgLayout="A:400px,G"
		xlLayout="A:400px,G"
		xxLayout="A:400px,G"		
	>
		<silk:Header >
			External Columns
		</silk:Header>
		<silk:Content>
			<silk:Form id="fkForm" dataSource="fkList" buttonTarget="null,fkFormPage" insertBt="fkAddBt" buttonTest="${editRight}" >
				<silk:Input id="columnName" type="text" label="Column Name" width="300px" required="true" />
				<silk:Input id="type" type="select" label="ORM Type" dataSource="columnTypeDP" required="true"
					valueColumn="columnTypeID" labelColumn="columnTypeLabel" width="200px"
				 />
				<silk:Input id="secure" type="checkbox" label="Secure" width="100px" block="true" />
				<silk:Input id="role" type="select" label="Tree Role" dataSource="columnRoleDP"
					valueColumn="columnRoleID" labelColumn="columnRoleLabel" width="300px" block="true"
				 />
				 <silk:Input id="id" type="hidden" value="getFkID()" />
			</silk:Form>
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="fkDP" pkColumn="id" />

	<silk:JQcode>
	
		getFkID = function(){
			if( fkForm.getAction()=="insert" ) return getUUID();
			return fkList.getSelectedItem().id;
		}
	
		fkFormPage.on("show", function(){
			formPage="G"
		});
		
		fkDP.on("afterLoad", function(action){
			if(action=="select") return;
			saveORM();
		});
		
	</silk:JQcode>

</silk:Module>



