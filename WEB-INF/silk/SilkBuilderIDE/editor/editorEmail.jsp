<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.oopsclick.silk.dbo.*,java.io.*" %>
<jsp:include page="../system/developerRole.jsp" flush="true"  />
<silk:App title="Email Editor" timeout="false" renderIf="read != ${developerRole}" >
	
	<silk:Screen>
		
		<silk:Page id="mailPage" stage="A"
			smLayout="A"
			mdLayout="A"
			rgLayout="A:400px"
			lgLayout="A:400px,B"
			xlLayout="A:400px,B"
			xxLayout="A:400px,B"
		>
			<silk:Header>
				Email Formatter
			</silk:Header> 
			<silk:Content>
				<silk:Form id="headForm" dataSource="headDP" buttonTarget="none,mailPage,none" buttonTest="none|${editRight}|none" >
					<silk:Input id="emailUUID" type="text" label="ID" editable="false" />
					<silk:Input id="wrapper" type="select" label="Wrapper" dataSource="templateDP"
						valueColumn="fileName" labelColumn="fileName" 
					/>
					<silk:Input id="sentFrom" type="text" label="From" placeholder="Defined at posting" hideEmpty="true" />
					<silk:Input id="replyTo" type="text" label="Reply To" placeholder="Defined at posting" hideEmpty="true" />
					<silk:Input id="copyTo" type="text" label="Copy To" placeholder="Defined at posting" hideEmpty="true" />
					<silk:Input id="blindTo" type="text" label="Blind Copy To" placeholder="Defined at posting" hideEmpty="true" />
				</silk:Form>
			</silk:Content>		
		</silk:Page>
		
		<silk:Page id="bodyPage" stage="B"
			smLayout="B:*:b"
			mdLayout="B:*:b"
			rgLayout="A:400px,B"
			lgLayout="A:400px,B"
			xlLayout="A:400px,B"
			xxLayout="A:400px,B"
		>
			<silk:Header>
				Body
			</silk:Header>
			<silk:Content>

				<silk:Tab id="langTab" />
				
				<silk:Form id="bodyForm" dataSource="bodyDP" buttonTarget="none,bodyPage,none" buttonTest="${editRight}" toggleEdit="!attachmentAddBt" >
					<silk:Input id="subject" type="text" label="Subject" required="true" />
					<silk:Input id="message" type="html" label="Message Body" required="true" htmlToolbar="regular" height="450px" />
					<silk:Input id="attachment" type="external" />
				</silk:Form>

				<silk:Table id="attachmentList" dataSource="attachmentDP" title="Attachment Links" header="inline" >
					<silk:TableHeader>
						<silk:Button id="attachmentAddBt" icon="add" dock="right" />
					</silk:TableHeader>
					<silk:TableBody>
						<silk:Column title="ID" width="50px" >{attachmentID}</silk:Column>
						<silk:Column title="File Path" >{filePath}</silk:Column>
						<silk:Column more="true" targetPage="attachmentModal" />
					</silk:TableBody>
				</silk:Table>
					
			</silk:Content>
		</silk:Page>

		<silk:Modal id="attachmentModal" title="Attachment Link" >
			<silk:Form id="attachmentForm" dataSource="attachmentList" insertBt="attachmentAddBt" buttonTarget="none,attachmentModal" >
				<silk:Input id="attachmentID" type="text" label="Identifier" required="true" autocomplete="false" />
				<silk:Input id="filePath" type="text" label="Path" required="true" />
			</silk:Form>
		</silk:Modal>
		
	</silk:Screen>

	<silk:DataProvider id="langDP" servicePath="/SilkBuilderIDE/system/LangOutlet" selectName="systemLang" pkColumn="langID" loadingOrder="1" />
	<silk:DataProvider id="templateDP" servicePath="/SilkBuilderIDE/theme/ThemeOutlet" selectName="emailFolder" loadingOrder="1" />
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content"  loadingOrder="2" />
	
	<silk:DataProvider id="headDP" pkColumn="silkEmailID" />
	<silk:DataProvider id="bodyDP" pkColumn="langID" />
	<silk:DataProvider id="attachmentDP" pkColumn="attachmentID" />
	
	<silk:JScode>
		var silkProjectID = "${urlParameter0}";
		var projectUUID = "${urlParameter2}";
		var projectPath = "";
		var toSave = false;
		var item;
		var xmlDoc;
		var bodyDoc;
	</silk:JScode>
	
	<silk:JQcode>
		bodyForm.$form.css("padding-bottom", "5px");
	</silk:JQcode>

	<silk:JQcode id="lang">
		
		langDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID", silkSystemID);
		});

		langDP.on("afterSelect", function(){
			for(x=0;x<langDP.size();x++){
				let item = langDP.getItemAt(x);
				langTab.addTab("langTab"+x, item.enName, undefined, false );
			}
			langTab.setIndex(0);
			bodyDP.setSelectedIndex(0);
		});

		langTab.on("click", function(index){
			bodyDP.setSelectedIndex(index);
			bodyForm.load();
		});

	</silk:JQcode>
	
	<silk:JQcode>

		templateDP.on("beforeSelect", function(){
			this.setParameter("silkSystemUUID", silkSystemUUID);
		});

		headForm.on("modeChange", function(){
			toSave = headForm.getMode();
		});
		
	</silk:JQcode>

	<silk:JQcode>

		bodyForm.on("afterLoad", function(){
			let json = bodyForm.attachment.getValue();
			attachmentDP.loadJSON(json);
		});
		
		bodyForm.on("afterModeChange", function(){
			toSave = bodyForm.getMode();
		});

		silk.on("resize", function(){
			//
		});
				
	</silk:JQcode>
	
	<silk:JQcode>
		
		contentDP.on("beforeSelect", function(){
			this.setParameter("silkProjectID", silkProjectID );
		});
		
		contentDP.on("afterSelect", function(action){

			/*
			 * Check Edit Rights.
			 */
			item = contentDP.getItem();

			projectPath = contentDP.getItem().projectPath;
			projectPath = replaceAll(projectPath,"//","/");
			
			loadEmail();
			
			/*
			 * Show editor after being loaded.
			 */
			$(window.frameElement).removeClass("silk-hidden");
			
		});

		/*
		 * Parses the JSON content
		 */
		loadEmail = function(){

			/*
			 * Parsing the project content
			 */
			var structure = JSON.parse(item.content);

			/*
			 * Loading the head
			 */
			headDP.selectObject.data.push(structure.head);
			headDP.selectObject.data[0].emailUUID = projectUUID;
			headDP.load();

			/*
			 * Loading the body
			 */
			bodyDP.selectObject.data = structure.body;

			/*
			 * Loading language into body
			 */
			let bodyArray = [];
			for( item of langDP.selectObject.data ){
				let bodyItem = {
					langID : item.langID,
					subject : "",
					message: "",
					attachment: ""
				};
				let contentItem = bodyDP.getIndexItem(item.langID);
				if( contentItem != undefined ){
					bodyItem.subject = contentItem.subject;
					bodyItem.message = contentItem.message;
					bodyItem.attachment = contentItem.attachment;
				}
				bodyArray.push(bodyItem);
			}
			bodyDP.selectObject.data = bodyArray;

			/*
			 * Initialize record index
			 */
			for( x=0; x<langDP.size(); x++ ){
				bodyDP.selectObject.data[x]["_recordIndex"] = x;
			}
			
			bodyDP.setSelectedIndex(0);
			bodyDP.load();

		};

	</silk:JQcode>
	
	<silk:JQcode renderIf="read != ${developerRole}" >
			
		headDP.on("afterUpdate",function(){
			saveStructure();
		});
		
		bodyDP.on("afterUpdate",function(){
			saveStructure();
		});
		
		saveStructure = function(){
			var structure = new Object();
			structure["head"] = headDP.selectObject.data[0];
			structure["body"] = bodyDP.selectObject.data;

			console.log( bodyDP.selectObject.data[0] );
			console.log( structure["body"][0] );
			
			contentDP.setParameter("silkProjectID", silkProjectID);
			contentDP.setParameter("content", JSON.stringify(structure));
			contentDP.exec("updateContent");
		};

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
		
	</silk:JQcode>

	<silk:JQcode>
		attachmentDP.on("afterLoad", function(action,operation){
			bodyForm.attachment.setValue(attachmentDP.getJSON());
			bodyDP.setSelectedIndex(langTab.getTabIndex());
		});

		attachmentForm.on("showInsertBt,showUpdateBt,showDeleteBt", function(){
			return bodyForm.getMode();
		});
		
	</silk:JQcode>
</silk:App>
