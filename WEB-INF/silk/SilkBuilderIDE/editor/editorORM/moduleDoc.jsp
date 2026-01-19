<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<style>
		#closeBt {
			border: 1px solid gray;
			padding: 4px;
			float: right;
		}
		
		#closeBt .silk-button-label {
			font-size: 1.2em;
		}
	</style>

	<silk:Modal id="docModal" size="full" bodyMargin="false" >
		<silk:Input id="docField" type="html" htmlConfigFile="/ckeditor-conf/bar-readonly.js" mode="true" />
		<silk:Button id="closeBt" label="Close" />
	</silk:Modal>


	<silk:JQcode>
	
		docField.$dataField.attr("class","");
		docField.$dataField.parent().attr("class","");
		docField.$dataField.parent().css("margin","0");
	
		docModal.on("show", function(){
			
			$(".cke_top").append($("#closeBt"));
			
			$("#cke_1_contents").height(docModal.$body.height());
			$("#cke_1_bottom").hide();
			
			var html = "";

			/*
			 * Description
			 */
			html += "<h1>Table: "+tableDP.getItem().tableName+"</h1>";
			
			html += "<h2>Description</h2>";
			html += "<div>"+tableDP.getItem().description+"</div>";

			/*
			 * Conceptual
			 */
			html += "<h2>Conceptual</h2>";
			html += "<table>";
			html += "<tr>";
				html += "<th></th>";
				html += "<th>Name</th>";
				html += "<th>Type</th>";
				html += "<th>Description</th>";
			html += "</tr>";
			
			for( var x=0; x < columnDP.size(); x++ ){
				html += "<tr>";
					html += "<td style='vertical-align:top;'><p>";
						if( columnDP.getItemAt(x,"pk")=="1" ) html += "PK";
					html += "</p></td>";
					html += "<td style='vertical-align:top;'><p>"+columnDP.getItemAt(x,"columnName")+"</p></td>";
					html += "<td style='vertical-align:top;'><p>"+renderType(0,0,columnDP.getItemAt(x,"type"))+"</p></td>";
					html += "<td style='vertical-align:top;'>"+ifUndefined(columnDP.getItemAt(x,"description"),"")+"</td>";
				html += "</tr>";
			}
			html += "</table>";

			/*
			 * Logical
			 */
			html += "<h2>Logical</h2>";
			html += "<table>";
			html += "<tr>";
				html += "<th></th>";
				html += "<th>Name</th>";

				for( y=0; y<databaseDP.size(); y++ ){
					let dbIndex = databaseDP.getItemAt(y).silkDatabaseID;
					if( tableForm.editorDatabaseID.getValue().indexOf(dbIndex)>-1 ){
						html += "<th>"+databaseDP.getItemAt(y).shortName+"</th>";
					}
				}
			
				html += "<th>Default</th>";
				html += "<th>Not&nbsp;Null</th>";
				html += "<th>Unique</th>";
				html += "<th>FK&nbsp;Table</th>";
				html += "<th>FK&nbsp;Column</th>";
				html += "<th>Index</th>";
			html += "</tr>";
			
			for( var x=0; x < columnDP.size(); x++ ){
				html += "<tr>";
					html += "<td style='vertical-align:top;'><p>";
						if( columnDP.getItemAt(x,"pk")=="1" ) html += "PK";
					html += "</p></td>";
					html += "<td style='vertical-align:top;'><p>"+columnDP.getItemAt(x,"columnName")+"</p></td>";

					for( y=0; y<databaseDP.size(); y++ ){
						let dbIndex = databaseDP.getItemAt(y).silkDatabaseID;
						if( tableForm.editorDatabaseID.getValue().indexOf(dbIndex)>-1 ){
							html += "<td style='vertical-align:top;'><p>"+columnDP.getItemAt(x,"sqlType"+dbIndex)+"</p></td>";
						}
					}
					
					html += "<td style='vertical-align:top;'><p>"+ifUndefined(columnDP.getItemAt(x,"defaultValue"+databaseID),"")+"</p></td>";
					html += "<td style='vertical-align:top;'><p align='center'>"
						if( ifUndefined(columnDP.getItemAt(x,"notNull"),"0")=="1" ) html += "X"
					html +"</p></td>";
					html += "<td style='vertical-align:top;'><p align='center'>"
						if( ifUndefined(columnDP.getItemAt(x,"unique"),"0")=="1" ) html += "X"
					html +"</p></td>";
					html += "<td style='vertical-align:top;'><p>"+ifUndefined(columnDP.getItemAt(x,"fkTable"),"")+"</p></td>";
					html += "<td style='vertical-align:top;'><p>"+ifUndefined(columnDP.getItemAt(x,"fkColumn"),"")+"</p></td>";
					html += "<td style='vertical-align:top;'><p align='center'>"
						if( ifUndefined(columnDP.getItemAt(x,"indexColumn"),"0")=="1" ) html += "X"
					html +"</p></td>";
				html += "</tr>";
			}
			html += "</table>";

			/*
			 * Physical
			 */
			html += "<h2>Physical</h2>";

			for( y=0; y<databaseDP.size(); y++ ){
				let dbIndex = databaseDP.getItemAt(y).silkDatabaseID;
				if( tableForm.editorDatabaseID.getValue().indexOf(dbIndex)==-1 ) continue;
				generateCreateTableSQL(
					ormObject.table,
					ormObject.column,
					dbIndex
				);
				html += "<h3>"+databaseDP.getItemAt(y).databaseName+"</h3>"
				html += renderCode(createSQL);
			}

			/*
			 * Select
			 */
			if( selectDP.size()==1 ){
				html += "<h2>Select</h2>";
			}else{
				html += "<h2>Selects</h2>";
			}
			
			for( var x=0; x < selectDP.size(); x++ ){
				if( selectDP.size()==1 && selectDP.getItemAt(x,"selectName").trim()=="default" ){
					html += "";
				}else{
					html += "<h3>"+selectDP.getItemAt(x,"selectName")+"</h3>";
				}
				html += ifUndefined(selectDP.getItemAt(x,"description"),"");

				for( y=0; y<databaseDP.size(); y++ ){
					let dbIndex = databaseDP.getItemAt(y).silkDatabaseID;
					if( tableForm.editorDatabaseID.getValue().indexOf(dbIndex)==-1 ) continue;
					html += "<h4>"+databaseDP.getItemAt(y).databaseName+"</h4>"
					var sql = ifUndefined(selectDP.getItemAt(x,"sql"+dbIndex),"");
					html += renderCode(sql);
					console.log( renderCode(sql) );
				}
				
			}
			
			/*
			 * Operation
			 */
			if( operationDP.size()>0 ){
			
				if( operationDP.size()==1 ){
					html += "<h2>Operation</h2>";
				}else{
					html += "<h2>Operations</h2>";
				}
					
				for( var x=0; x < operationDP.size(); x++ ){
					var operationName = operationNameRenderer(0,operationDP.getItemAt(x),operationDP.getItemAt(x).type);
					
					html += "<h3>"+operationName+"</h3>";
					html += ifUndefined(operationDP.getItemAt(x,"description"),"");

					for( y=0; y<databaseDP.size(); y++ ){
						let dbIndex = databaseDP.getItemAt(y).silkDatabaseID;
						if( tableForm.editorDatabaseID.getValue().indexOf(dbIndex)==-1 ) continue;
						html += "<h4>"+databaseDP.getItemAt(y).databaseName+"</h4>"
						var sql = ifUndefined(operationDP.getItemAt(x,"sql"+databaseID),"");
						html += renderCode(sql.trim());
					}
					
				}
			}
			
			docField.setValue(html);			
			
			setTimeout(function(){
				CKEDITOR.instances.docField_input.execCommand('maximize');
			}, 100);
			
		});
		
		closeBt.on("click",function(){
			CKEDITOR.instances.docField_input.execCommand('maximize');
			docModal.close();
		});
		
	</silk:JQcode>

</silk:Module>



