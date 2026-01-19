<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<jsp:include page="../system/developerRole.jsp" flush="true"  />
<silk:App title="Index App" renderIf="read != ${developerRole}" >

	<silk:Screen>

		<silk:Page id="testListPage" stage="A1"
			smLayout="A1"
			mdLayout="A1"
			rgLayout="A1:500px,A2"
			lgLayout="A1:500px,A2"
			xlLayout="A1:500px,A2"
			xxLayout="A1:500px,A2"
		>
			<silk:Header >
				Session Profiles
			</silk:Header>
			<silk:Content>
				<silk:Table id="testList" dataSource="testDP" header="none" >
					<silk:Column ordering="true" />
					<silk:Column>{testName}</silk:Column>
					<silk:Column align="right"><i class="fa-solid fa-square-check" keepIf="{position}==0" style="color:#c6fe3a" ></i></silk:Column>
					<silk:TableEmpty>
						No test created.
					</silk:TableEmpty>
				</silk:Table>
				
				<p>&nbsp;</p>
				<silk:Table id="sessionList" dataSource="sessionDP" header="inline" title="Servlet Session" selectable="false" cssClass="table-sm" >
					<silk:TableHeader>
						<silk:Button id="sessionRefreshBt" icon="fa-solid fa-rotate" dock="right" />
					</silk:TableHeader>
					<silk:Column title="Attribute">{attribute}</silk:Column>
					<silk:Column title="Value">{value}</silk:Column>
				</silk:Table>
				
				<p>&nbsp;</p>
				<div align="center" >
					<silk:Button id="clearSessionBt" label="Clear Session" confirmTitle="Confirm Clearing Session" />
					<silk:Button id="clearRoleBt" label="Clear Roles" confirmTitle="Confirm Clearing Roles" />
				</div>
			</silk:Content>
		</silk:Page>
			
		<silk:Page id="testFormPage" stage="A2"
			smLayout="A2:*:b"
			mdLayout="A2:*:b"
			rgLayout="A1:500px,A2"
			lgLayout="A1:500px,A2"
			xlLayout="A1:500px,A2"
			xxLayout="A1:500px,A2"
		>
			<silk:Header >
				Session Attributes
			</silk:Header>
			<silk:Content>
				<silk:Form id="testForm" dataSource="testList" buttonTarget="testListPage,testFormPage" >
					<silk:Input id="testName" type="text" label="Test Name" required="true" />
					<silk:Input id="silkUserID" type="text" label="silkUserID" width="150px" />
					<silk:Input id="variableList" type="textarea" label="Session Variables" height="100px" />
					<silk:Input id="roleList" type="textarea" label="Testing Roles" height="100px" />
					<silk:Input id="position" type="hidden" value="testForm.getAction()=='insert'? testDP.size() : testList.getSelectedItem().position" />
					<silk:Input id="silkSystemID" type="hidden" value="${urlParameter1}" />
					<silk:Input id="silkDeveloperID" type="hidden" value="${silkDevID}" />
					<silk:Input id="silkTestingID" type="hidden" />
				</silk:Form>			
			</silk:Content>
		</silk:Page>
		
	</silk:Screen>

	<silk:DataProvider id="testDP" servicePath="/SilkBuilderIDE/test/TestingOutlet" selectName="sessionList" />
	
	<silk:DataProvider id="sessionDP" >	
	</silk:DataProvider>

	<silk:JQcode>

		testDP.on("beforeSelect", function(){
			this.setParameter("silkSystemID","${urlParameter1}");
		});
	
		testForm.deleteBtVisible = function(){
			if( testList.selectedIndex==0 ){
				if( testDP.size()>1 ) return false;
			}
			return true
		};
		
		$(window.frameElement).removeClass("silk-hidden");
		
		
		sessionRefreshBt.on("click", function(){
			clearSession();
		});
		
		clearSessionBt.on("click", function(){
			clearSession("2");
		});

		clearRoleBt.on("click", function(){
			clearSession("1");
		});
		
		clearSession = function(action){
			if( action==undefined ) action=0;
			$.get("{contextPath}/service/SilkBuilderIDE/test/ClearSession?action="+action,function(data, status){
				sessionDP.selectObject.data = JSON.parse(data);
				sessionList.load();
			});
		}
		
		clearSession();
		
	</silk:JQcode>

</silk:App>
