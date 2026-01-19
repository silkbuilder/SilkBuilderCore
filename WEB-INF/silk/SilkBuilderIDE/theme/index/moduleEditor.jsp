<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
	<script src="{contextPath}/silk/codeEditor/csseditor.js"></script>
	<script src="{contextPath}/silk/codeEditor/htmleditor.js"></script>
	
	<silk:Modal id="editorModal" title="Editor" closeButton="true" size="full"  bodyMargin="false" >
		<div id="cssEditor" style="height: 400px;" ></div>
	</silk:Modal>
	
	<silk:Modal id="uploadModal" title="Upload Bootstrap File" closeButton="true" >
		<silk:Input id="bootstrapFile" type="file" mode="true" uploadURL="{contextPath}/service/SilkBuilderIDE/theme/uploadFile" />
	</silk:Modal>
	
	<silk:Button id="saveBt" icon="fa-solid fa-floppy-disk fa-lg" cssClass="silk-navbar-button" />
	
	<silk:DataProvider id="fileDP" servicePath="/SilkBuilderIDE/theme/ThemeOutlet" selectName="themeFile" autoLoad="false" />
	
	<silk:JScode>
	
		var cssEditor = new HtmlEditor("cssEditor","dark");
		
		resizeEditor = function(){
			$("#cssEditor").height(window.innerHeight-editorModal.$header.outerHeight());
		}		
		
		var changeMonitor;
		var codeChanged = false;
		
	</silk:JScode>

	<silk:JQcode>
	
		editorModal.$header.css("padding","10px");
	
		openEditorBt.on("click", function(){
			if( filesList.getSelectedItem().fileName=="bootstrap.min.css" ){
				uploadModal.show();
			}else{
				cssEditor.clean();
				if( themeList.getSelectedItem().root==1 ){
					cssEditor = new HtmlEditor("cssEditor","dark");
				}else{
					cssEditor = new CssEditor("cssEditor","dark");
				}
				fileDP.select();
			}
		});

		$("#cssEditor").on("keydown", function(key){
			
			if( !isIn(key.which,38,40,39,37,91) ) saveBt.show();

			clearTimeout(changeMonitor);
			changeMonitor = setTimeout(function(){
				if( cssEditor.getCode() == fileDP.getItem().content ){
					saveBt.hide();
					codeChanged = false;
				}else{
					codeChanged = true;
				}
			},300);
			
			// Presed Save keyboard shortcut
			if( key.which==83 && (key.ctrlKey || key.metaKey) ){
				saveBt.$button.trigger('click');
				key.preventDefault();
				key.stopPropagation();
			}
		});

		
	</silk:JQcode>
	
	<silk:JQcode>
	
		editorModal.$header.find(".silk-navbar-right").append( saveBt.$button );
		saveBt.hide();
	
		fileDP.on("beforeSelect", function(){
			
			if( themeList.getSelectedItem().root==1 ){
				this.setParameter("themeName","..");
			}else{
				this.setParameter("themeName",themeList.getSelectedItem().fileName);
			}
			
			this.setParameter("silkSystemUUID",silkSystemUUID);
			this.setParameter("fileID",filesList.getSelectedItem().fileID);
			
		});

		fileDP.on("afterSelect", function(){
			editorModal.setTitle( filesList.getSelectedItem().fileName+" Editor" );
			cssEditor.setCode( fileDP.getItem().content );
			editorModal.show();
		});
		
		editorModal.on("show", function(){
			resizeEditor();
		});
		
		editorModal.on("beforeClose", function(){
			if( codeChanged ){
				silk.alert({
					title: "Do you want to save the changes?",
					showCancelButton: true,
					cancelButtonText: "Close only",
					confirmButtonText: "Save & Close",
				}).then((result) => {
					if (result.isConfirmed) {
			 			saveBt.$button.trigger('click');
			 			editorModal.close();
					}else{
						editorModal.close();
					}
				});
				return false;
			}			
		});
		
		editorModal.on("close", function(){
			if( themeList.getSelectedItem().root==1 ) return;
			loadSample();
		});
		
		saveBt.on("click", function(){
			fileDP.setOperationItem("content", cssEditor.getCode() );
			fileDP.setOperationItem("fileID", fileDP.getItem().fileID );
			fileDP.update();
			saveBt.hide();
			codeChanged = false;
		});
		
		$(window).resize(function(){
			resizeEditor();
		});
		
	</silk:JQcode>
	
	<silk:JQcode>
		
		bootstrapFile.on("beforeUpload", function(input,dataForm){
			dataForm.append("silkSystemUUID", silkSystemUUID);
			dataForm.append("themeName", themeList.getSelectedItem().fileName);
		});
		
		bootstrapFile.on("afterUpload", function(){
			bootstrapFile.setValue("");
			bootstrapFile.setMode(true);
			uploadModal.hide();
		});
		
	</silk:JQcode>
	
</silk:Module>
