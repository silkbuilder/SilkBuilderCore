<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<%@ page import="
		com.oopsclick.silk.dbo.*,
		java.io.*
	"
%>
<jsp:include page="../system/checkRights.jsp" flush="true" >
	<jsp:param name="writeRoles" value="admin,architect,developer" />
</jsp:include>

<silk:App title="Code Editor" timeout="false" >

	<script src="{contextPath}/silk/silkDev.min.js?loadTime={loadTime}"></script>
	<link rel="stylesheet" href="{contextPath}/resources/diff2html/diff2html.min.css?loadTime={loadTime}">
	<script src="{contextPath}/resources/diff2html/diff2html-ui.min.js?loadTime={loadTime}"></script>
	
	<style>
	
		#editorBar {
			padding: 0px !important;
		}s
	
		#editorBar button {
			padding: 1px !important;
		}

		#editorBar button:hover {
			text-decoration: none;
		}
	
		.title {
			float: left;
			padding-left: 5px;
			font-weight: 400;
			font-size: 1em;
		}

		#changeModal .modal-header {
			padding: 8px 6px;
		}

		#changeModal .modal-title {
			font-size: 1em;
		}

		#silkCodeHistoryID, #silkCodeHistoryID_input {
			width: 350px !important;
		}

		.d2h-dark-color-scheme {
			background-color: #212529 !important;
		}
		
	</style>
	
    <style>

        /* Set editor dimensions */
        #silkEditor{
          font-size: 1em;
          height: 100vh;
          width: 100%;
        }

        /* Stretch editor to fit inside its containing div */
        .cm-editor {
            height: 100%;
            width: 100%;
        }

        .cm-editor-readonly {
          xbackground-color: red;
        }

        .silk-code-tag {
        	color: #c792ea;
        }

        .silk-js-tag {
        	color: #ffdd02;
        }

        .silk-jq-tag {
        	color: deepskyblue;
        }

		.cm-panels-bottom {
			font-size: 1.2em;
		}
		
        .cm-search button[name=close]{
        	color:white;
        }
		
    </style>
	
	<script src="{contextPath}/silk/codeEditor/silkeditor.js?loadTime={loadTime}"></script>
	
	<nav id="editorBar" class="navbar silk-header-bg" >
		<div class="container-fluid py-1">
			<div class="title">
				<i class="fa-solid fa-angle-right"></i>
				<span id="editorTitle" ></span>&nbsp;&nbsp;
			</div>
			<div>
				<silk:Button icon="fa-solid fa-code-compare" targetPage="changeModal" cssClass="btn-lg btn-link silk-navbar-button" renderIf="${isPro}" />
				<silk:Button id="infoBt" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF;font-family:monospace;" renderIf="${editRight}" />
				<silk:Button id="searchBt" icon="fa-solid fa-magnifying-glass fa-lg" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF" renderIf="${editRight}" />
				<silk:Button id="saveBt" icon="fa-solid fa-save fa-lg" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF" renderIf="${editRight}" />
				<silk:Button id="tagBt" icon="fa-solid fa-tags fa-lg" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFCC66" renderIf="${editRight}" />
			</div>
		</div>
	</nav>

	<div id="silkEditor"></div>

	<silk:Modal id="changeModal" title="Code Changes" size="full" bodyMargin="false" renderIf="${isPro}" >
		<silk:Input id="fullCode" type="checkbox" label="Full" mode="true" />
		<silk:Input id="silkCodeHistoryID" type="select" dataSource="changeListDP" labelColumn="operationDate" mode="true" />
		<silk:Input id="viewType" type="select" dataSource="viewTypeDP" valueColumn="value" labelColumn="label" mode="true" />
		<div id="diffBox"></div>
	</silk:Modal>
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" />
	
	<silk:DataProvider id="changeListDP" servicePath="/SilkBuilderIDE/system/CodeHistoryOutlet" selectName="list" autoLoad="false" renderIf="${isPro}" />
	<silk:DataProvider id="changeCodeDP" servicePath="/SilkBuilderIDE/system/CodeHistoryOutlet" selectName="content" autoLoad="false" renderIf="${isPro}" />

	<silk:DataProvider id="viewTypeDP" >
		0:Side by Side
		1:Line by Line
	</silk:DataProvider>
	
	<silk:JScode>
	
		var silkProjectID = "${urlParameter0}";
	
		parent.codeFrame = window;
		
		var item = null;
		var projectPath = "";
		var toSave = false;
	
		var silkEditor = new SilkEditor("silkEditor");
		silkEditor.setDarkTheme();
		<silk:If renderIf="${editRight}" negation="true" >
			silkEditor.setReadOnly(true)
		</silk:If>
		
		resizeEditor = function(){
			$("#silkEditor").height(window.innerHeight-$("#editorBar").outerHeight());
		}
		
		var changeMonitor;

		var selectedTag;
		var silkTag;
		var helpWindow;
		
	</silk:JScode>

	<silk:JQcode>

		searchBt.on("click", function(){
			silkEditor.openSearch();
		});
	
		saveBt.hide();
	
		$("#silkEditor").on("keydown", function(key){

			/*
			 * Check copy keyboard and cancel it.
			 */
			if ((key.ctrlKey || key.metaKey) && key.code === 'KeyC') return;
			
			/*
			* Ignored Keys
			* 16 Shift
			* 17 Control
			* 18 Alt
			* 20 CapsLock
			* 27 Escape
			* 33 PageUp
			* 34 PageDown
			* 35 End
			* 36 Home
			* 37 Arrow Left
			* 38 Arrow Up
			* 39 ArrowRight
			* 40 ArrowDown
			* 45 Insert
			* 91 Meta Left - Mac Command
			* 92 Meta Right 
			*/
			if( isIn(key.which,16, 17, 18, 20, 27, 33, 34, 35, 36, 37, 38, 39, 40, 45, 91,92 ) ) return;
				
			saveBt.show();
			toSave = true;
			
			clearTimeout(changeMonitor);
			changeMonitor = setTimeout(function(){
				if( silkEditor.getCode() == item.content ){
					toSave = false;
					saveBt.hide();
				}
			},300);
			
			// Presed Save keyboard shortcut
			if( key.which==83 && (key.ctrlKey || key.metaKey) ){
				saveBt.$button.trigger('click');
				key.preventDefault();
				key.stopPropagation();
			}
		});
		
		contentDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", silkProjectID );
		});
		
		contentDP.on("afterSelect", function(action){

			// Load content		
			item = contentDP.getItem();
			silkEditor.setCode( javaIn(item.content) );
			resizeEditor();

			projectPath = contentDP.getItem().projectPath;
			projectPath = replaceAll(projectPath,"//","/");

			let titleText = projectPath;
			if( contentDP.getItem().commitDate!="" ){
				titleText += " | Last Sync: " +	getFormattedValue(contentDP.getItem().commitDate,"datetime");
			}

			$("#editorTitle").html(titleText);

			<silk:If renderIf="${isPro}" >
				changeModal.setTitle( "Changes for "+projectPath );
			</silk:If>
			
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
			
		});
		
		<silk:If renderIf="${editRight}" >
		
			saveBt.on("click", function(){
				let content = javaOut(silkEditor.getCode())
				if( content != item.content ){
					contentDP.setParameter("silkProjectID", silkProjectID );
					contentDP.setParameter("content", content);
					contentDP.exec("updateContent");
					item.content = content;
				}
				saveBt.hide();
				toSave = false;
				silkEditor.editor.focus();
			});
			
			// Saves content into files
			contentDP.on("afterExec", function(){
				var url = "{contextPath}/service/SilkBuilderIDE/system/saveCode";
				
				$.ajax({
					url: url,
					data: { silkProjectID: silkProjectID },
					success: function(data) {},
					error: function() {},
					type: 'POST'
				});
			});

			tagBt.on("click", function(){
				parent.window["tagListPage"].show();
				parent.window["tagDP"].select();
			});

			infoBt.on("click", function(){
				if( helpWindow!=undefined )	helpWindow.close();
				helpWindow = window.open("https://docs.silkbuilder.com/tags/"+silkTag, "_blank");
			});

			/*
			document.addEventListener("selectionchange", () => {

				console.log("x");
									  
				let $selected = $(".cm-matchingBracket");
				if( $selected.length>0 ){
					selectedTag = $selected[0].textContent;
				}else{
					$selected = $(".cm-nonmatchingBracket");
					if( $selected.length>0 ){
						selectedTag = $selected.text();
					}else{
						const pos = silkEditor.editor.state.selection.main.from;
						const silkTag = silkEditor.getCode().lastIndexOf(atob("PA==")+"silk:", pos);

						if( silkTag > -1  ){
							const closeTag = silkEditor.getCode().lastIndexOf(atob("Pg=="),pos);
							if( silkTag > closeTag ){
								const endTag = silkEditor.getCode().indexOf(" ",silkTag);
								selectedTag = silkEditor.getCode().substring(silkTag+1,endTag);
								// console.log( "> "+selectedTag );
							}
						}
					}
				}

				if( selectedTag==undefined) return;
				
				if( selectedTag.indexOf("silk:")==-1){
					selectedTag = "";
					silkTag = "";
				}else{
					silkTag = selectedTag.replace("silk:","").toLowerCase();
					selectedTag = atob("PA==")+selectedTag+atob("Pg==")
				}			
	
				infoBt.setLabel(selectedTag);
				selectedTag = "";
				
			});
			*/
		
		</silk:If >

		$(window).resize(function(){
			resizeEditor();
		});
		
	</silk:JQcode>

	<silk:JQcode  renderIf="${isPro}" >

		changeModal.$header.find(".silk-navbar-right").append(fullCode.$input);
		fullCode.$input.css("margin","2px 5px 0px 0px");
		fullCode.$input.css("width","150px");
		
		changeModal.$header.find(".silk-navbar-right").append(silkCodeHistoryID.$input);
		silkCodeHistoryID.$input.css("margin","2px 5px 0px 0px");
		silkCodeHistoryID.$dataField.css("padding","0px 36px 0px 12px");
		silkCodeHistoryID.$dataField.css("width","350px !important");

		changeModal.$header.find(".silk-navbar-right").append(viewType.$input);
		viewType.$input.css("margin","2px 0px 0px 0px");
		viewType.$dataField.css("padding","0px 36px 0px 12px");
		
		changeModal.on("beforeShow", function(){
			changeListDP.select();
		});

		silkCodeHistoryID.on("filterLoad", function(index,item){
			changeListDP.setItemAt(index,"operationDate", 
				getFormattedValue(item.operationDate,"datetime")+" "+item.fullName
			);
			return true;
		});
		
		silkCodeHistoryID.on("change", function(){
			changeCodeDP.select();
		});

		viewType.on("change", function(){
			changeCodeDP.select();
		});

		fullCode.on("change", function(){
			changeCodeDP.select();
		});
		
		changeListDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", silkProjectID );
			this.setParameter("silkCodeHistoryID", contentDP.getItem().lastSyncID );
		});
		
		changeListDP.on("afterSelect", function(){
			changeCodeDP.select();
		});

		changeCodeDP.on("beforeSelect", function(){
			this.setParameter("silkCodeHistoryID", silkCodeHistoryID.getValue() );
		});

		changeCodeDP.on("afterSelect", function(){
			let content = javaIn(changeCodeDP.getItem().content);
			silkShowDiff(content, silkEditor.getCode(), viewType.getValue(), fullCode.getValue()==1);
		});
		
	</silk:JQcode>

	
</silk:App>