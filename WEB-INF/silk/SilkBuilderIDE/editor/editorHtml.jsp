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

<silk:App title="Code Editor" timeout="false" jsLib="HTML-Editor" >

	<style>

		#htmlEditor {
			height: calc(100vh - 5px);
			display: block;
			overflow: hidden;
		}

		.ql-toolbar {
			border-color: #495057 !important;
		}
		
		.ql-container {
			height: calc(100vh - 40px);
		}
		
	</style>

	<silk:Button id="saveBt" icon="save" label="Save" cssClass="btn-primary btn-sm" width="75px" renderIf="${editRight}" />
	<div id="htmlEditor" ></div>
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content" />
	
	<silk:JScode>
		var silkProjectID = "${urlParameter0}";
		var quillEditor;
	</silk:JScode>

	<silk:JQcode>

		<silk:If renderIf="${editRight}" >
			
			const myToolbar = [
				['bold', 'italic', 'underline', 'strike'],
				[{ 'align': [] }],
				[{ 'header': [1, 2, 3, 4, 5, 6, false] }, 'code-block'],
				['link', 'image'],			
				[{ 'list': 'ordered'}, { 'list': 'bullet' }],
				[{ 'script': 'sub'}, { 'script': 'super' }],
				[{ 'indent': '-1'}, { 'indent': '+1' }],			
				[{ 'color': [] }, { 'background': [] }],			
				['table-better'],			
				['clean']
			];
			
			quillEditor = new QuillEditor($("#htmlEditor"),"", myToolbar);
			//$(".ql-container").height(500);
			$(".ql-formats").last().append(saveBt.$button);
			
		</silk:If>
		
		contentDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", silkProjectID );
		});
		
		contentDP.on("afterSelect", function(action){
			var item = contentDP.getItem();

			<silk:If renderIf="${editRight}" >
				quillEditor.setHtml(item.content);
				$(".ql-editor").scrollTop(0);
			</silk:If>
			<silk:If renderIf="${editRight}" negation="true" >
				$("#htmlEditor").html(item.content);
			</silk:If>
			
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
			
		});

		<silk:If renderIf="${editRight}" >
			saveBt.on("click", function(){
				var data = quillEditor.getHtml();
				if( data != contentDP.getItem("content") ){
					contentDP.setParameter("silkProjectID", silkProjectID);
					contentDP.setParameter("content", data);
					contentDP.exec("updateContent");
					contentDP.setItem("content",data);
				}
			});
		</silk:If>
			
	</silk:JQcode>

</silk:App>