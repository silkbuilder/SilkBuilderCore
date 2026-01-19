<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%
	response.setCharacterEncoding("UTF-8");
	response.setContentType("application/json");
%>
<jsp:include page="../../../silk/service/view/dataProvider.jsp" >
	<jsp:param name="ormPath" value="../silk/SilkBuilderIDE/silkTesting" />
	<jsp:param name="selectList" value=",sessionList," />
</jsp:include>