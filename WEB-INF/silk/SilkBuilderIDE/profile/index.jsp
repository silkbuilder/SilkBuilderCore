<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<silk:App>
	
	<main>

		<jsp:include page="../menu/index/moduleHeader.jsp" >
			<jsp:param name="title" value="Profile" />
		</jsp:include>
		
		<div class="py-3" >
			<div class="container" >
				<silk:Tab id="profileTab" >
					<%@ include file="index/moduleAccount.jsp" %>
					<%@ include file="index/moduleMFA.jsp" %>
				</silk:Tab>
			</div>
		</div>
		
	</main>

	<silk:DataProvider id="developerDP" servicePath="/SilkBuilderIDE/developer/DeveloperOutlet" selectName="developerProfile" />
						
	<%@ include file="../menu/index/moduleFooter.jsp" %>
		
</silk:App>