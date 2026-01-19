<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8"%>
<jsp:include page="../system/developerRole.jsp" flush="true"  />
<silk:App title="Variables App" renderIf="read != ${developerRole}" >

	<silk:Screen>
		<%@ include file="index/moduleGroup.jsp" %>
		<%@ include file="index/moduleVariable.jsp" %>
	</silk:Screen>

	<script>
	<silk:JQcode>

		var silkSystemID = "${urlParameter1}";
	
	</silk:JQcode>
	</script>
	
</silk:App>
