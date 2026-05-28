<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<%@ taglib uri="/WEB-INF/silk.tld" prefix="silk" %>
<%@page contentType="text/html;charset=UTF-8" %>
<silk:App title="">
	html editor
	<silk:Input id="myEditor" type="html" mode="true" htmlConfigFile="/ckeditor-conf/bar-complex.js" height="800px" />

	<div id="code" >
<h1>H1 silkLang</h1>

<p>asdfasdf</p>

<p>asdfasdf</p>

<p>asdfasdf</p>

<p>asdfsadf</p>

<h2>H2&nbsp;silkLang</h2>

<h3>H3&nbsp;silkLang</h3>

<h4>H4&nbsp;silkLang</h4>

<h5>H5&nbsp;silkLang</h5>

<h2>Description</h2>

<p>This is a description of some nice text to show</p>

<p>List 1</p>

<p>List 2</p>

<p>List 3</p>

<p>List 4</p>

<p>Paragraph 1</p>

<p>Paragraph 2</p>

<h2>Conceptual</h2>

<table>
	<tbody>
		<tr>
			<th>&nbsp;</th>
			<th>Name</th>
			<th>Type</th>
			<th>Description</th>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>PK</p>
			</td>
			<td style="vertical-align:top">
			<p>silkLangID</p>
			</td>
			<td style="vertical-align:top">
			<p>Integer</p>
			</td>
			<td style="vertical-align:top">sdfgfd</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>langID</p>
			</td>
			<td style="vertical-align:top">
			<p>String</p>
			</td>
			<td style="vertical-align:top">
			<ul style="padding-left: 25px !important; padding-right: 0px !important;">
				<li>adsfadsf</li>
				<li>asdfsadf</li>
				<li>asdfsadf</li>
			</ul>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>langName</p>
			</td>
			<td style="vertical-align:top">
			<p>String</p>
			</td>
			<td style="vertical-align:top">
			<p>This is a large text with many areas to check</p>

			<p>Another paragraph to check.</p>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>enName</p>
			</td>
			<td style="vertical-align:top">
			<p>String</p>
			</td>
			<td style="vertical-align:top">&nbsp;</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>status</p>
			</td>
			<td style="vertical-align:top">
			<p>Integer</p>
			</td>
			<td style="vertical-align:top">&nbsp;</td>
		</tr>
	</tbody>
</table>

<h2>Logical</h2>

<table>
	<tbody>
		<tr>
			<th>&nbsp;</th>
			<th>Name</th>
			<th>MySQL</th>
			<th>MSSQL</th>
			<th>PgSQL</th>
			<th>ORCL</th>
			<th>Default</th>
			<th>Not&nbsp;Null</th>
			<th>Unique</th>
			<th>FK&nbsp;Table</th>
			<th>FK&nbsp;Column</th>
			<th>Index</th>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>PK</p>
			</td>
			<td style="vertical-align:top">
			<p>silkLangID</p>
			</td>
			<td style="vertical-align:top">
			<p>int</p>
			</td>
			<td style="vertical-align:top">
			<p>int</p>
			</td>
			<td style="vertical-align:top">
			<p>int</p>
			</td>
			<td style="vertical-align:top">
			<p>int</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>langID</p>
			</td>
			<td style="vertical-align:top">
			<p>char(2)</p>
			</td>
			<td style="vertical-align:top">
			<p>char(2)</p>
			</td>
			<td style="vertical-align:top">
			<p>char(2)</p>
			</td>
			<td style="vertical-align:top">
			<p>char(2)</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>langName</p>
			</td>
			<td style="vertical-align:top">
			<p>varchar(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>nvarchar(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>varchar(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>nvarchar2(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>enName</p>
			</td>
			<td style="vertical-align:top">
			<p>varchar(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>varchar(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>varchar(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>varchar2(100)</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
		</tr>
		<tr>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>status</p>
			</td>
			<td style="vertical-align:top">
			<p>tinyint</p>
			</td>
			<td style="vertical-align:top">
			<p>tinyint</p>
			</td>
			<td style="vertical-align:top">
			<p>smallint</p>
			</td>
			<td style="vertical-align:top">
			<p>smallint</p>
			</td>
			<td style="vertical-align:top">
			<p>0</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
			<td style="vertical-align:top">
			<p>&nbsp;</p>
			</td>
		</tr>
	</tbody>
</table>

<h2>Physical</h2>

<h3>MySQL</h3>

<div class="code-block">
<div class="code-line">create table silkLang (</div>

<div class="code-line">&nbsp;&nbsp;&nbsp;&nbsp;silkLangID int primary key auto_increment,</div>

<div class="code-line">&nbsp;&nbsp;&nbsp;&nbsp;langID char(2),</div>

<div class="code-line">&nbsp;&nbsp;&nbsp;&nbsp;langName varchar(100),</div>

<div class="code-line">&nbsp;&nbsp;&nbsp;&nbsp;enName varchar(100),</div>

<div class="code-line">&nbsp;&nbsp;&nbsp;&nbsp;status tinyint default 0</div>

<div class="code-line">);</div>
</div>

<h3>&nbsp;</h3>


	</div>
	
<silk:JScode>
</silk:JScode>

<silk:JQcode>
	myEditor.setValue( $("#code").html() );
	$("#code").html("");
</silk:JQcode>

</silk:App>


