<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page import="
			com.oopsclick.silk.dbo.*,
			com.oopsclick.silk.utils.Tools,
			com.oopsclick.silk.utils.SilkPath
		"
%>
<%

	/*
	 * Loading silkSystemID parameter
	 */
	String silkSystemID = request.getParameter("silkSystemID");
		
	/*
	 * Loading silkProjectUUID parameter
	 */
	String silkProjectID = request.getParameter("silkProjectID");
	if( silkProjectID==null ) silkProjectID="";

	/*
	 * File code extraction
	 */
	DataProvider codeDP = new DataProvider("/../silk/SilkBuilderIDE/silkProject",session);
	codeDP.setParameter("silkSystemID", silkSystemID);
	codeDP.setParameter("silkProjectID", silkProjectID);
	codeDP.select("sync-files");
	for(int x=0; x<codeDP.size(); x++){
		
		/*
		 * Filling code array
		 */
		String filePath = codeDP.getStringItem(x,"filePath");
		String fileName = codeDP.getStringItem(x,"fileName");

		System.out.println(filePath);
		System.out.println(fileName);
		
	}
	
%>