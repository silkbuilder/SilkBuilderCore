<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ page
	import="
		com.oopsclick.silk.utils.FileTool,
		com.oopsclick.silk.utils.SilkPath,
		com.oopsclick.silk.security.Crypt	
	"
	trimDirectiveWhitespaces="true"
	language="java"
	contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8"
%>
<%

	/*
	 * Load the new password
	 */
	String newPassword = request.getParameter("newPassword");
	if( newPassword==null ) return;

	/*
	 * Load user.pwd file and extracts the password.
	 * If the file does not exist the password is empty characters.
	 */
	String path = SilkPath.getRealPath(request);
	path += "WEB-INF/user.pwd";

	/*
	 * Encrypt and hass the new password
	 */
	Crypt crypt = new Crypt();
	newPassword = crypt.passwordHashing(newPassword);

	/*
	 * Write the password to the file
	 */
	FileTool.writeFile(path, newPassword );	
	
	
%>