<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@ page contentType="text/html;charset=UTF-8"%>
<%
	String silkSystemUUID = (String) request.getAttribute("urlParameter0");
	String theme = (String) request.getAttribute("urlParameter1");
	theme = "../../theme/"+silkSystemUUID+"/"+theme+"*";
%>
<silk:App title="Sample" timeout="false" theme="<%= theme %>" >

	<silk:Screen>
	
		<silk:Page id="themeListPage" stage="A"
		smLayout="A"
		mdLayout="A"
		rgLayout="A:300px,B"
		lgLayout="A:300px,B"
		xlLayout="A:300px,B"
		xxLayout="A:300px,B"
	>
		<silk:Header>
			Header
		</silk:Header>
		<silk:Content>
		
			<silk:Table id="peopleList" dataSource="peopleDP" title="Table" header="inline"  >
				<silk:Column title="Name" >{name}</silk:Column>
				<silk:Column title="Email">{email}</silk:Column>
			</silk:Table>
			
			<silk:Group title="Buttons" >
				<button type="button" class="btn btn-primary">Primary</button>
				<button type="button" class="btn btn-secondary">Secondary</button>
				<button type="button" class="btn btn-success">Success</button>
				<button type="button" class="btn btn-danger">Danger</button>
				<button type="button" class="btn btn-warning">Warning</button>
				<button type="button" class="btn btn-info">Info</button>
				<button type="button" class="btn btn-light">Light</button>
				<button type="button" class="btn btn-dark">Dark</button>
				<button type="button" class="btn btn-link">Link</button>
			</silk:Group>
			
			<silk:Form id="testForm" >
				<silk:Input id="name" type="text" label="Name" />
			</silk:Form>
			
			<silk:Group title="Tabs" >
				<silk:Tab id="tab1">
					<silk:TabItem id="option1" title="Option1" >
						<p>
							Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean pharetra. Donec non ligula.
							Integer dictum dapibus massa. Etiam eleifend lorem id lorem. Phasellus purus dolor, porta eu, eleifend et, hendrerit ut, est. Nullam justo.
							Integer wisi. Nam accumsan. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Quisque quis enim. Curabitur diam.
							Nam et lorem non enim iaculis feugiat. Vivamus hendrerit. Donec nisl massa, feugiat sit amet, elementum vitae, eleifend non, lectus.
							Cras ante. Sed in risus quis ligula placerat sodales. Aenean posuere nonummy diam.
						</p>
					</silk:TabItem>
					<silk:TabItem id="option2" title="Option2" >
						<p>
							Morbi quis nisl. Nulla mauris. Aliquam tincidunt, risus et suscipit imperdiet, wisi nulla commodo mi, in commodo massa tortor ut pede.
							Cras et lacus a sem dapibus malesuada. In eget lorem. Curabitur sed ipsum vitae orci ultricies pellentesque. Donec id quam in nunc semper porta.
							Nunc varius. Praesent luctus, tellus at tristique rhoncus, leo wisi pharetra lorem, vel posuere risus arcu vel tellus. Donec porta. Nunc eu arcu.
							Aliquam leo sem, vestibulum sed, fermentum quis, placerat a, lorem.
						</p>
					</silk:TabItem>
				</silk:Tab>
			</silk:Group>
						
		</silk:Content>
	</silk:Page>
	
	</silk:Screen>

	<silk:DataProvider id="peopleDP" >
		{"id":"0", "name":"Mark Foxlin", "email":"peter@mail.com"},
		{"id":"1", "name":"Cleo Abram", "email":"cleo@mail.com"}
	</silk:DataProvider>


</silk:App>
