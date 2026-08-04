<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<style>
		#docModal .modal-body {
			overflow-y: clip !important;
		}
	</style>

	<silk:Button id="printBt" icon="print" cssClass="btn-link silk-navbar-button btn-lg border-0" />
	<silk:Modal id="docModal" title="ORM Documentation" size="full" bodyMargin="false" >
		<iframe id="docField" style="width:100%; background-color:white; border: none;" ></iframe>
	</silk:Modal>


	<silk:JQcode>

		docModal.$header.find(".silk-navbar-right").append(printBt.$button);
		
		docModal.on("show", function(){

			$("#docField").height($("#docField").parent().outerHeight());
			
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

			html += "<h3>Columns</h3>";
			html += "<table>";
			html += "<tr>";
				html += "<th>Name</th>";
				for( y=0; y<databaseDP.size(); y++ ){
					let dbIndex = databaseDP.getItemAt(y).silkDatabaseID;
					if( tableForm.editorDatabaseID.getValue().indexOf(dbIndex)>-1 ){
						html += "<th>"+databaseDP.getItemAt(y).databaseName+"</th>";
					}
				}
			html += "</tr>";
			
			for( var x=0; x < columnDP.size(); x++ ){
				html += "<tr>";
					html += "<td style='vertical-align:top;'><p>"+columnDP.getItemAt(x,"columnName")+"</p></td>";

					for( y=0; y<databaseDP.size(); y++ ){
						let dbIndex = databaseDP.getItemAt(y).silkDatabaseID;
						if( tableForm.editorDatabaseID.getValue().indexOf(dbIndex)>-1 ){
							html += "<td style='vertical-align:top;'><p>"+columnDP.getItemAt(x,"sqlType"+dbIndex)+"</p></td>";
						}
					}
				html += "</tr>";
			}
			html += "</table>";

			html += "<h3>Properties</h3>";
			html += "<table>";
			html += "<tr>";
				html += "<th></th>";
				html += "<th>Name</th>";
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
						if( ifUndefined(columnDP.getItemAt(x,"fkTable"),"")!="" ) html += "FK";
					html += "</p></td>";
					html += "<td style='vertical-align:top;'><p>"+columnDP.getItemAt(x,"columnName")+"</p></td>";
					
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

			html = html.replaceAll("\{dbTable\}", tableDP.getItem().tableName);

			html = "<html><head>"+
					"<link rel='stylesheet' href='{contextPath}/silk/print.css?"+(new Date()).getTime()+"' >"+
				"</head><body>"+html+"</body></html>";
			
			const iframe = document.getElementById('docField');
			iframe.srcdoc = html;
			
		});

	printBt.on("click", function(){
	    const iframe = document.getElementById("docField");
	    
	    // Target the iframe's internal window context
	    const iframeWindow = iframe.contentWindow;
	    
	    // Focus the frame (highly recommended for multi-browser support)
	    iframeWindow.focus();
	    
	    // Trigger the print dialog
	    iframeWindow.print();
	});
		
	</silk:JQcode>

</silk:Module>



