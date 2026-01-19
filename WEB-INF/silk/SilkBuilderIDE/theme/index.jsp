<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@ page contentType="text/html;charset=UTF-8"%>
<%@ page import="com.oopsclick.silk.dbo.DataProvider" %>
<jsp:include page="../system/developerRole.jsp" flush="true" />
<silk:App title="Index App" renderIf="admin,architect one-in ${developerRole}" >

	<silk:Screen>
		<%@ include file="index/moduleFolder.jsp" %>
		<%@ include file="index/moduleFiles.jsp" %>
		<%@ include file="index/moduleSample.jsp" %>
		<%@ include file="index/moduleEditor.jsp" %>
	</silk:Screen>
	
</silk:App>
