<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page import="java.util.Date"%>
<%@page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.oopsclick.silk.dbo.*,java.io.*" %>

<jsp:include page="../system/checkRights.jsp" flush="true" >
	<jsp:param name="writeRoles" value="admin,architect" />
</jsp:include>

<silk:App title="Code Editor" timeout="false" >

	<script src="{contextPath}/resources/ckeditor/adapters/jquery.js"></script>

	<style>

		html, body {
			height: 100%;
		}
		
		.title {
			line-height: 1.7em;
			font-size: 1.2em;
		}
		
	</style>
	
	<form>
		<textarea id="htmlEditor"></textarea>
	</form>
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" autoLoad="false" />
	
	<silk:JScode>
		var saveBt = new Button();
		var silkProjectID = "${urlParameter0}";
	</silk:JScode>

	<silk:JQcode>
	
		// Configuring html Editor
		$htmlEditor = $('#htmlEditor');
		$htmlEditor.ckeditor({
			customConfig: "{contextPath}/ckeditor-conf/bar-developer.js?a=<%= (new Date()).getTime() %>"
			<silk:If renderIf="${editRight}" negation="true"  >
				,readOnly: true
			</silk:If>
		});
		
		CKEDITOR.on( 'instanceReady', function( ev ){
			resizeEditor();
			
			contentDP.load();
			
			// Create a new command with the desired exec function
			var overridecmd = new CKEDITOR.command(ev.editor, {
				exec: function(editor){
					// Replace this with your desired save button code
					saveData();
				}
			});

			// Replace the old save's exec function with the new one
			ev.editor.commands.save.exec = overridecmd.exec;
			
		} )
		
		resizeEditor = function(){
			CKEDITOR.instances["htmlEditor"].resize("100%",$("body").height());
		}
	
		<silk:If renderIf="${editRight}" >
			CKEDITOR.instances["htmlEditor"].on( 'key', function( event, editor, data ) {
				$(".cke_button__save").css("background-color","red");
			} );
		</silk:If>
		
		$(window).resize(function(){
			resizeEditor();
		});
		
		
		contentDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", silkProjectID );
		});
		
		
		contentDP.on("afterSelect", function(action){

			//Check Edit Rights.
			
			var item = contentDP.getItem();

			CKEDITOR.instances["htmlEditor"].setData( item.content );
			var projectPath = contentDP.getItem().projectPath;
			projectPath = replaceAll(projectPath,"//","/");
			$("#cke_1_top").prepend("<span class='title'>&nbsp;"+projectPath+"</span><br/>");
			resizeEditor();
			
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
			
		});
		
		<silk:If renderIf="${editRight}" >
			saveData = function(){
				var data = CKEDITOR.instances["htmlEditor"].getData();
				if( data != contentDP.getItem("content") ){
					contentDP.setParameter("silkProjectID", silkProjectID);
					contentDP.setParameter("content", data);
					contentDP.exec("updateContent");
					$(".cke_button__save").css("background-color","");
					contentDP.setItem("content",data);
				}
			}
		</silk:If>
		<silk:If renderIf="${editRight}" negation="true" >
			saveData = function(){
				silk.alert("Warning","You have read ony access.","warning");
			}
		</silk:If>
			
	</silk:JQcode>

</silk:App>