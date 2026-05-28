<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<silk:App>
	
	<script src="{contextPath}/silk/silkDev.min.js?loadTime={loadTime}"></script>

	<style>
		
		#silkDatabaseID {
			margin: 0px !important;
		}
		
		#codeBox {
			font-family: monospace, monospace;
			font-size: 0.9em;
			padding: 20px;
			margin-top: 50px;
		}

		.code-block {
			list-style-type: none;
			counter-reset: css-counter 0;
		}

		.code-block div {
			counter-increment: css-counter 1
		}

		.code-block div:before {
			content: counter(css-counter) ". ";
			color: gray;
		}

		.silk-navbar-button {
			padding: 2px !important;
		}

		red {
			background-color: red;
			padding: 2px;
			color: yellow;
		}
		
	</style>
	
	<nav id="editorBar" class="navbar fixed-top bg-primary" style="display: block;" >
		<div>
			Generate Database Script
			&nbsp;&nbsp;
			<silk:Input id="silkDatabaseID" type="select" dataSource="databaseDP" mode="true" width="200px"
				valueColumn="silkDatabaseID" labelColumn="databaseName" prompt="Select..."
			/>
			<silk:Button id="downloadBt" icon="fa-solid fa-file-arrow-down fa-lg" cssClass="silk-navbar-button" />
			<silk:Button id="clipboardBt" icon="fa-solid fa-clipboard fa-lg" cssClass="silk-navbar-button" />
		</div>	
	</nav>

	<div id="codeBox" ></div>

	<silk:DataProvider id="projectDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="databaseProject" />
	<silk:DataProvider id="databaseDP" servicePath="/SilkBuilderIDE/database/DatabaseOutlet" selectName="targetDatabaseList" loadingOrder="2" />
	<silk:DataProvider id="objectDB" servicePath="/SilkBuilderIDE/system/ProjectOutlet" selectName="dbObjectList" pkColumn="projectName" />

	<silk:JScode>
		var code = "";
		var title = "${urlParameter2} - "+(new Date()).toDateString();
		var fileTitle = "";
	</silk:JScode>

	<silk:JQcode>
		projectDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", "${urlParameter0}");
		});
	</silk:JQcode>
	
	<silk:JQcode>
		databaseDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", "${urlParameter1}");
		});

		databaseDP.on("afterLoad", function(){
			$(window.frameElement).removeClass("silk-hidden");
			if( databaseDP.size()==1 ){
				silkDatabaseID.setValue( databaseDP.getItem().silkDatabaseID );
				buildSQL();
			}else{
				setTimeout( function(){silkDatabaseID.openSelect();},500);
			}
		});

		silkDatabaseID.on("change", function(){
			if( silkDatabaseID.getValue()=="" ){
				code="";
				$("#codeBox").html("");
				return;	
			} 
			buildSQL();
		});

	</silk:JQcode>
	
	<silk:JQcode>
		objectDB.on("beforeSelect", function(){
			this.setParameter("silkSystemID", "${urlParameter1}");
			this.setParameter("silkProjectID", "${urlParameter0}");
		});

		objectDB.on("afterSelect", function(){
			for(x=0; x<objectDB.size(); x++){
				var item = objectDB.getItemAt(x);
				if ( isEmpty(item.content) ){
					objectDB.getItemAt(x)["json"] = {};
				}else{
					objectDB.getItemAt(x)["json"] = JSON.parse(item.content);
				}
				
				
				objectDB.getItemAt(x)["order"] = 0;
				objectDB.getItemAt(x)["fkParent"] = [];
 			}
		});
	</silk:JQcode>

	<silk:JQcode>

		sortSQL = function(){
			for(x=0; x<objectDB.size(); x++){
				var item = objectDB.getItemAt(x);
				if( item.fkParent.length > 0 ){
					for(const parentTable of  item.fkParent){
						const parentIndex = objectDB.getIndex(parentTable);
						if( x < parentIndex ){
							const element = objectDB.selectObject.data.splice(x,1)[0];
							objectDB.selectObject.data.splice(parentIndex,0,element);
							sortSQL();
							return;
						}
					}
				}
			}
		}
		
		buildSQL = function(){

			var errorMsg = "";
			
			for(x=0; x<objectDB.size(); x++){
				var item = objectDB.getItemAt(x);
				if( item.nodeType=="ORM" ){
					objectDB.getItemAt(x)["sql"] = generateCreateTableSQL(
						item.json.table,
						item.json.column,
						silkDatabaseID.getValue()
					)+"\n\n";
					objectDB.getItemAt(x).projectName = item.json.table.tableName;

					for(y=0; y<item.json.column.length; y++ ){
						column = item.json.column[y];
						if( ifUndefined(column.fkTable,"")!="" ){
							const index = objectDB.getIndex(column.fkTable);
							if( index > -1 ){
								objectDB.getItemAt(x).fkParent.push(column.fkTable);
							}else{
								errorMsg += "-- Table:"+item.json.table.tableName+". Column:"+column.columnName+": <red>FK Table does not exist: "+column.fkTable+"</red>\n";
							}
						}
					}
					
				} else {
					objectDB.getItemAt(x)["sql"] = ifUndefined(item.json["sql"+silkDatabaseID.getValue()],"-- No Provided").trim()+"\n\n";
					if( item.nodeType=="DBTR" ) objectDB.getItemAt(x).order = objectDB.getItemAt(x).order+1000;
					if( item.nodeType=="DBPR" ) objectDB.getItemAt(x).order = objectDB.getItemAt(x).order+2000;
					if( item.nodeType=="DBVW" ) objectDB.getItemAt(x).order = objectDB.getItemAt(x).order+3000;
				}
			};
			
			objectDB.selectObject.data.sort(function (l, r) {
				return l.order - r.order;
			});

			sortSQL();
			
			fileTitle = projectDP.getItem().projectName+" "+(new Date()).toISOString().substr(0,16);
			fileTitle = fileTitle.replaceAll(" ","_")
			
			code = "";
			code += "-- ======================================================\n";
			code += "-- System: ${urlParameter3}\n";
			if( projectDP.getItem().projectLevel>0 ){
				code += "-- Project: /";
				if( projectDP.getItem().projectLevel==2 ){
					code += projectDP.getItem().containerName+"/";
				}
				code += projectDP.getItem().projectName+"\n";
			}
			code += "-- ======================================================\n";
			code += "-- SQL File: "+fileTitle+".sql\n";
			code += "-- ======================================================\n\n";

			if( errorMsg!="" ){
				code += "-- ******************************************************\n";
				code += "-- Foreing Key Tables\n";
				code += errorMsg;
				code += "-- ******************************************************</red>\n\n";
			}
			
			for(x=0; x<objectDB.size(); x++){
				let item = objectDB.getItemAt(x);

				let nodeTypeName = "";
					
				if( item.nodeType=="ORM" ) nodeTypeName = "TABLE: ";
				if( item.nodeType=="DBTR" ) nodeTypeName = "TRIGGER: ";
				if( item.nodeType=="DBPR" ) nodeTypeName = "PROGRAM: ";
				if( item.nodeType=="DBVW" ) nodeTypeName = "VIEW: ";
			
				code += "-- ------------------------------------------------------\n"
				code += "-- "+nodeTypeName+item.projectName+"\n"
				code += "-- ------------------------------------------------------\n"
				code += item.sql.trim()+";\n\n";
			}

			code += "\n";
			code += "-- ======================================================\n";
			code += "-- SQL script end\n";
			code += "-- ======================================================";

			code = code.replaceAll(";;",";");
			
			if( code.indexOf("<red>")>-1 ){
				code = "<red>* HAS ERRORS</red>\n\n"+code;
			}
			
			$("#codeBox").html(renderCode(code));
		}

		downloadBt.on("click", function(){
			if( silkDatabaseID.getValue()=="" ) return;
			downloadText(code,"text/plain",fileTitle+".sql");
			silk.toast("Code downloaded.");
		});

		clipboardBt.on("click", function(){
			navigator.clipboard.writeText(code);
			silk.toast("Code copied to clipboard.");
		});
		
	</silk:JQcode>

</silk:App>
