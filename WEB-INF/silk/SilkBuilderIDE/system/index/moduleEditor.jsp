<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
	<style>
		
		#tabEditor button {
			padding-right: 10px !important;
		}
		
		#tabEditor .close-icon {
			padding-left: 7px !important;
		}
		
		#editorPage .silk-content {
			padding: 3px 0px 0px 0px;
			overflow: clip !important;
		}
		
		.tab-pane {
			padding: 2px;
			margin: 0px;
		}
		
	</style>
	
	<silk:Page id="editorPage" stage="B1" returnPage="structureListPage"
		smLayout="B1:*:b"
		mdLayout="B1:*:b"
		rgLayout="A1:300px,B1"
		lgLayout="A1:400px,B1"
		xlLayout="A1:400px,B1"
		xxLayout="A1:500px,B1"
	>
		<silk:Content>
			<span id="editorPage_backBt" class="fa-solid fa-chevron-left fa-lg silk-button-icon" aria-hidden="true" style="padding:20px 5px 0px 5px;"></span>
			<silk:Tab id="tabEditor" ></silk:Tab>
		</silk:Content>
	</silk:Page>
	
	<silk:JScode>

		/*
		 * Close tab
		 */
		closeTab = function(e){
			
			var tabID = $(e).parent().attr("id").replace("_tab","");
			var tabIndex = -1;
			
			for( x in tabEditor.getTabs() ){
				if( tabEditor.getTabs()[x].id==tabID ){
					tabIndex = x;
					break;
				}
			}

			if( tabIndex == -1 ) return;

			let toSave = window.frames["frame-"+tabID].contentWindow["toSave"];
			if( toSave==undefined ) toSave = false;

			if( toSave ){
				silk.confirmation(
					function(index){
						tabEditor.removeTab(index);
						projectDP.setParameter("silkProjectID", tabID.replace("T",""));
						projectDP.exec("projectItemUnlock");
					},
					tabIndex,
					"Unsaved Editor",
					"Do you want to close this unsaved editor? Your changes may be lost.",
					"Close Editor",
					"question"
				);
			}else{
				tabEditor.removeTab(tabIndex);
				projectDP.setParameter("silkProjectID", tabID.replace("T",""));
				projectDP.exec("projectItemUnlock");
			}

			if( tabEditor.getTabs().length==0 ) structureListPage.show();
			
		};
		
	</silk:JScode>
	
	<silk:JQcode>

		tabEditor.$tab.prepend( $("#editorPage_backBt") );

		/*
		 * Open a new tab editor, or focus it if it is already open.
		 */
		openTab = function(item){
			
			var tabID = "T"+item.silkProjectID;
			var index = tabEditor.indexOf(tabID);

			if( index==-1 ){
			
				var url = "";
				
				// Editor Selection
				// ------------------------------------------------
				
				/*
				 * Loads Code Editor
				 */
				if( item.editor==1 ) url = contextPath+"/service/SilkBuilderIDE/editor/editorCode/"+item.silkProjectID+"/"+silkSystemID;

				/*
				 * Loads Outlet Editor
				 */
				if( item.editor==6 ) url = contextPath+"/service/SilkBuilderIDE/editor/editorOutlet/"+item.silkProjectID+"/"+silkSystemID;

				/*
				 * Loads Email Editor
				 */
				if( item.editor==7 ) url = contextPath+"/service/SilkBuilderIDE/editor/editorEmail/"+item.silkProjectID+"/"+silkSystemID+"/"+item.projectUUID;

				/*
				 * Loads HTML Editor
				 */
				if( item.editor==2 ) url = contextPath+"/service/SilkBuilderIDE/editor/editorHtml/"+item.silkProjectID+"/"+silkSystemID;
				
				/*
				 * Loads ORM Editor
				 */
				if( item.editor==4 ) url = contextPath+"/service/SilkBuilderIDE/editor/editorORM/"+item.silkProjectID+"/"+silkSystemID+"/"+item.nodeType;
				
				/*
				 * Loads DB Object (SQL) Editor
				 */
				if( item.editor==5 ) url = contextPath+"/service/SilkBuilderIDE/editor/editorSQL/"+item.silkProjectID+"/"+silkSystemID;
				
				/*
				 * Configuration
				 */
				if( item.editor==91 ) url = contextPath+"/service/SilkBuilderIDE/setup/index/"+item.silkProjectID+"/"+silkSystemID;

				/*
				 * Testing
				 */
				if( item.editor==92 ) url = contextPath+"/service/SilkBuilderIDE/test/index/"+item.silkProjectID+"/"+silkSystemID;
				
				/*
				 * Variables
				 */
				if( item.editor==93 ) url = contextPath+"/service/SilkBuilderIDE/variable/index/"+item.silkProjectID+"/"+silkSystemID;

				/*
				 * Theme
				 */
				if( item.editor==94 ) url = contextPath+"/service/SilkBuilderIDE/theme/index/"+item.silkProjectID+"/"+silkSystemID;

				/*
				 * Translation
				 */
				if( item.editor==95 ) url = contextPath+"/service/SilkBuilderIDE/translation/index/"+item.silkProjectID+"/"+silkSystemID;

				/*
				 * Translation
				 */
				if( item.editor==97 ) url = contextPath+"/service/SilkBuilderIDE/email/index/"+item.silkProjectID+"/"+silkSystemID;
				
				/*
				 * Database Generator
				 */
				if( item.editor==96 ){
					url = contextPath+"/service/SilkBuilderIDE/database/createDatabase/"+item.silkProjectID+"/"+silkSystemID+"/"+item.projectName+"/"+systemName;
					structureListPage.show();
				}
				
				// End of Editor Selection
				// ------------------------------------------------

				console.log(url);
				
				const closeTabIcon = "<a href='#' onCLick='closeTab(this)'><i class='close-icon fa-solid fa-square-xmark text-danger'></i></a>";
				const tabContent = "<iframe id='frame-"+tabID+"' src='"+url+"' style='width:100%; border: 0px;' class='editor-frame silk-hidden' allow='clipboard-write; clipboard-read' ></iframe>"+
					"<div style='margin:10px;' >Loading...</div>"+
					"<div class='progress' role='progressbar' aria-label='Animated striped example' aria-valuenow='100' aria-valuemin='0' aria-valuemax='100' style='margin:10px;' >"+
						"<div class='progress-bar progress-bar-striped progress-bar-animated bg-info' style='width: 100%'></div>"+
					"</div>";
			
				tabEditor.addTab(
					tabID,
					"<span>"+item.projectName+"</span>"+closeTabIcon,
					tabContent
				);
				
				tabEditor.getSelectedTab()["silkProjectID"] = item.silkProjectID;
				tabEditor.getSelectedTab()["nodeType"] = item.nodeType;
				tabEditor.getSelectedTab()["projectUUID"] = item.projectUUID;

				if( item.nodeType=="MOD" ){
					tabEditor.getSelectedTab()["tagProjectUUID"] = projectDP.getIndexItem(item.parentID).projectUUID;
				}else{
					tabEditor.getSelectedTab()["tagProjectUUID"] = item.projectUUID;
				}

				//setTimeout(function(){
				//},3000);
				
			}else{
				tabEditor.setIndex(index);
			}

			editorPage.show();
		}
		
		tabEditor.on("add,click",function(index){
			
			adjustEditor();
			
			if( tagListPage.getVisible() ){
				if( ("APP,CSF,PUB,CSFP,MOD").indexOf(tabEditor.getSelectedTab().nodeType)!=-1 ){
					if( tagProjectID != tabEditor.getSelectedTab().tagProjectUUID ){
						tagDP.select();
					}
				}else{
					editorPage.show();
				}
			}
			
			/*
			 * Focusing and clearing selection.
			 */
			let tabID = "frame-"+tabEditor.getTabs(index).id;
			if( window.frames[tabID] ){
				
				window.frames[tabID].contentWindow.focus();
				if( window.frames[tabID].contentWindow.silkEditor ){
					window.frames[tabID].contentWindow.silkEditor.editor.dispatch({selection: {anchor: 0,head: 0}})
				}
				window.frames[tabID].contentWindow.getSelection().removeAllRanges();
			}
			
		});

		/*
		 * Sets the editor's height.
		 */
		adjustEditor = function(){
			if( tabEditor.index==-1 ) return;
			$("#frame-"+tabEditor.getSelectedTab().id).height(editorPage.$content.outerHeight()-tabEditor.$tab.outerHeight());
		};
		
		$(window).resize(function(){
			adjustEditor();
		});

	</silk:JQcode>
	
</silk:Module >
