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

	<style>
	
		#editorBar {
			padding: 0px !important;
		}
	
		#editorBar button {
			padding: 1px !important;
		}

		#editorBar button:hover {
			text-decoration: none;
		}
	
		.title {
			float: left;
			xmargin-top: 5px;
			padding-left: 5px;
			font-weight: 400;
			font-size: 1em;
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
				<silk:Button id="infoBt" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF;font-family:monospace;" renderIf="${editRight}" />
				<silk:Button id="searchBt" icon="fa-solid fa-magnifying-glass fa-lg" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF" renderIf="${editRight}" />
				<silk:Button id="saveBt" icon="fa-solid fa-save fa-lg" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFFFFF" renderIf="${editRight}" />
				<silk:Button id="tagBt" icon="fa-solid fa-tags fa-lg" dock="right" cssClass="btn-lg btn-link silk-navbar-button" cssStyle="color:#FFCC66" renderIf="${editRight}" />
			</div>
		</div>
	</nav>

	<div id="silkEditor"></div>
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" />
	
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
			* 37 ArrowLeft
			* 38 ArowUp
			* 39 ArrowRight
			* 40 ArrowDown
			* 45 Insert
			* 91 Meta Left
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

			//Check Edit Rights.
			
			item = contentDP.getItem();
			
			var codeString = item.content;
			item.content = replaceAll(item.content, atob("PCU="), atob("PGphdmE+"));
			item.content = replaceAll(item.content, atob("JT4="), atob("PC9qYXZhPg=="));
			
			silkEditor.setCode( item.content );
			resizeEditor();
			projectPath = contentDP.getItem().projectPath;
			projectPath = replaceAll(projectPath,"//","/");
			$("#editorTitle").html( projectPath );
			
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
			
		});
		
		<silk:If renderIf="${editRight}" >
		
			saveBt.on("click", function(){
				if( silkEditor.getCode() != item.content ){
					item.content = silkEditor.getCode();
					item.content = replaceAll(item.content, atob("PGphdmE+"), atob("PCU="));
					item.content = replaceAll(item.content, atob("PC9qYXZhPg==") , atob("JT4="));
					
					contentDP.setParameter("silkProjectID", silkProjectID );
					contentDP.setParameter("content", item.content);
					contentDP.exec("updateContent");
				}
				saveBt.hide();
				toSave = false;
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

</silk:App>