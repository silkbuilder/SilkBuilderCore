<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
    
	<silk:Modal id="copySelectModal" limitedClose="false" >		
	</silk:Modal>

	<silk:JScode>
		var copyForm = "";
		var copyTo = 0;
		var positionX;
		var positionY
	</silk:JScode>
	
	<silk:JQcode>

		$(".copy-sql").mousemove(function(event){
			positionX = event.pageX;
			positionY = event.pageY;
		});
		
		copySelectModal.on("beforeShow", function(){
			fillCopyModal();
			window[copyForm].setUpdate();
		});

		fillCopyModal = function(){
			let html = "<div class='fw-bold' >Copy From</div>";
			for( x in databaseDP.selectObject.data ){
				let databaseName = databaseDP.selectObject.data[x].databaseName;
				let silkDatabaseID = databaseDP.selectObject.data[x].silkDatabaseID;
				if( silkDatabaseID==copyTo ) continue;
				if( tableForm.editorDatabaseID.getValue().indexOf(","+silkDatabaseID+",")==-1 ) continue;
				html += "<div class='btn-group' role='group' aria-label='Basic example' style='width:100%;' >";
				html += "<button class='btn btn-primary btn-sm' onClick='copySelect("+silkDatabaseID+",false)' style='width:100%;' >"+databaseName+"</button>";
				if( copyForm=="columnForm" ) html += "<button class='btn btn-success btn-sm' onClick='copySelect("+silkDatabaseID+",true)' >All</button>";
				html += "</div>";

			}
			copySelectModal.$body.html( html );
		};
		
		copySelect = function(from, allColumns){
			if( copyForm=="columnForm" ){
				/*
				 * Copy all columns values
				 */
				if( allColumns ){
					for( let x in  columnDP.selectObject.data ){
						
						let typeValue = columnDP.selectObject.data[x]["sqlType"+from];
						
						/*
						 * Adjust for postgresql
						 */
						if( copyTo==3 && typeValue.toLowerCase()=="tinyint") typeValue="smallint";
						if( copyTo==3 && typeValue.toLowerCase()=="datetime") typeValue="timestamp";

						/*
						 * Adjust for SQL Server
						 */
						if( copyTo==1 && typeValue.toLowerCase()=="text") typeValue="nvarchar(max)";
						if( copyTo==1 && typeValue.toLowerCase()=="timestamp") typeValue="datetime";
						
						
						columnDP.selectObject.data[x]["sqlType"+copyTo] = typeValue;
						if( columnDP.selectObject.data[x]["defaultValue"+from] ){
							columnDP.selectObject.data[x]["defaultValue"+copyTo] = columnDP.selectObject.data[x]["defaultValue"+from];
						}
						if( columnDP.selectObject.data[x]["function"+from] ){
							columnDP.selectObject.data[x]["function"+copyTo] = columnDP.selectObject.data[x]["function"+from];
						}
						if( columnDP.selectObject.data[x]["functionInsert"+from] ){
							columnDP.selectObject.data[x]["functionInsert"+copyTo] = columnDP.selectObject.data[x]["functionInsert"+from];
						}
						if( columnDP.selectObject.data[x]["functionUpdate"+from] ){
							columnDP.selectObject.data[x]["functionUpdate"+copyTo] = columnDP.selectObject.data[x]["functionUpdate"+from];
						}
					}
				}

				window[copyForm]["sqlType"+copyTo].setValue(window[copyForm]["sqlType"+from].getValue());
				window[copyForm]["defaultValue"+copyTo].setValue(window[copyForm]["defaultValue"+from].getValue());
				window[copyForm]["function"+copyTo].setValue(window[copyForm]["function"+from].getValue());
				window[copyForm]["functionInsert"+copyTo].setValue(window[copyForm]["functionInsert"+from].getValue());
				window[copyForm]["functionUpdate"+copyTo].setValue(window[copyForm]["functionUpdate"+from].getValue());
			}else{
				window[copyForm]["sql"+copyTo].setValue(window[copyForm]["sql"+from].getValue());
			}
			copySelectModal.close();
		};
		
	</silk:JQcode>
	
</silk:Module >