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
				<!-- silk:Button id="getMimeBt" icon="fa-solid fa-file-arrow-down" dock="right" / -->
			</silk:Header>
			<silk:Content>

				<silk:Tab id="langTab" />
				
				<silk:Form id="bodyForm" dataSource="bodyDP" buttonTarget="none,bodyPage,none" buttonTest="${editRight}" >
					<silk:Input id="subject" type="text" label="Subject" required="true" />
					<silk:Input id="message" type="html" label="Message Body" required="true"
						htmlConfigFile="/ckeditor-conf/bar-developer.js"
					/>
					<silk:Input id="langID" type="hidden" />
				</silk:Form>
			</silk:Content>		
		</silk:Page>
		
	</silk:Screen>

	<silk:DataProvider id="langDP" servicePath="/SilkBuilderIDE/system/LangOutlet" selectName="systemLang" pkColumn="langID" loadingOrder="1" />
	<silk:DataProvider id="templateDP" servicePath="/SilkBuilderIDE/theme/ThemeOutlet" selectName="emailFolder" loadingOrder="1" />
	
	<silk:DataProvider id="contentDP" servicePath="/SilkBuilderIDE/system/ContentOutlet" selectName="content"  loadingOrder="2" />
	
	<silk:DataProvider id="headDP" pkColumn="silkEmailID" />
	<silk:DataProvider id="bodyDP" pkColumn="langID" />
	
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
		bodyPage.$content.css("padding-bottom",0)
		bodyForm.$form.css("padding-bottom","0");
		bodyForm.message.$input.css("margin-bottom","0")
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
		});

		langTab.on("click", function(index){
			bodyDP.setSelectedIndex(index);
			bodyForm.load();
		});
		
	</silk:JQcode>
	
	<silk:JQcode>

		templateDP.on("beforeSelect", function(){
			console.log(silkSystemUUID);
			this.setParameter("silkSystemUUID", silkSystemUUID);
		});

		headForm.on("modeChange", function(){
			toSave = headForm.getMode();
		});
		
	</silk:JQcode>

	<silk:JQcode>

		bodyForm.on("afterModeChange", function(){
			resizeMessage();
			toSave = bodyForm.getMode();
		});

		silk.on("resize", function(){
			resizeMessage();
		});
		
		resizeMessage = function(){
			setTimeout( function(){
				bodyForm.message.$input.find(".cke_contents").height(bodyForm.$form.parent().height()-200);
			},200);
		}
		
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
			//bodyDP.load();
			
			/*
			 * Loading language into body
			 */
			let bodyArray = [];
			for( item of langDP.selectObject.data ){
				let bodyItem = {
					langID : item.langID,
					subject : "",
					message: ""
				};
				let contentItem = bodyDP.getIndexItem(item.langID);
				if( contentItem != undefined ){
					bodyItem.subject = contentItem.subject;
					bodyItem.message = contentItem.message;
				}
				bodyArray.push(bodyItem);
			}
			bodyDP.selectObject.data = bodyArray;
			bodyDP.setSelectedIndex(0);
			bodyDP.load();

		};
		
		getNodeValue = function(doc,tag,mode){
			if( mode==undefined ) mode=0;
			if( doc.getElementsByTagName(tag).length>0 ){
				if( mode==0 ) return doc.getElementsByTagName(tag)[0].childNodes[0].nodeValue;
				if( mode==1 ) return doc.getElementsByTagName(tag)[0].textContent.trim()
			}
			return "";
		};
		
		<silk:If renderIf="read != ${developerRole}" >
			
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
		
		</silk:If>
			
	</silk:JQcode>
	
</silk:App>
