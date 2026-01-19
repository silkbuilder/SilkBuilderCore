<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Modal id="importColumnModal" title="Import Columns" >
		<p>
			This option will export the columns from the specified table within the given database.
		</p>
		<silk:Input id="importColumnDatabaseID" type="select" dataSource="databaseDP" mode="write" required="true"
			valueColumn="silkDatabaseID" labelColumn="databaseName" prompt="Select engine..."
		/>
		<silk:Input id="importColumnDatabaseName" type="text" label="Database" mode="write" required="true" />
		<silk:Input id="importColumnTable" type="text" label="Table" mode="write" required="true" />
		<div align="right" >
			<silk:Button id="importColumnExtractBt" label="Import" />
		</div>
	</silk:Modal>

	<silk:DataProvider id="importColumnDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="tableColumns" autoLoad="false" />
	
    <silk:JScode>
        let result="hello";
    </silk:JScode>
    
    <silk:JQcode>
		
        importColumnModal.on("beforeShow", function(){
			importColumnDatabaseName.setValue("");
			importColumnTable.setValue(tableForm.tableName.getValue());
		});

		importColumnExtractBt.on("beforeClick", function(){
			if( importColumnDatabaseID.getValue()=='' || importColumnDatabaseName.getValue()=='' || importColumnTable.getValue()=='' ){
				silk.alert("Warning","Complete required data.","warning");
				return false; 
			}
		});

		importColumnExtractBt.on("click", function(){
			importColumnDP.select();
		});

		importColumnDP.on("beforeSelect", function(){
			this.setParameter("databaseEngine", importColumnDatabaseID.getValue());
			this.setParameter("databaseName", importColumnDatabaseName.getValue());
			this.setParameter("tableName", importColumnTable.getValue());
		});

		importColumnDP.on("afterSelect", function(){
			if( importColumnDP.size()==0 ){
				silk.alert("Warning","No columns returned.","warning");
			}else{
				importColumnModal.hide();
				columnDP.selectObject.data = importColumnDP.selectObject.data;
				columnDP.load();
				saveORM();
			}
		});
		
    </silk:JQcode>

</silk:Module >
