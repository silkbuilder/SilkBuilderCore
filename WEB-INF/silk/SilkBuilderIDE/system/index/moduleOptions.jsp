<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:DataProvider id="menuDP" >
		<silk:If renderIf="read!=${developerRole}" >
			{
				"silkProjectID":"SYSROOT",
				"projectName":"Options",
				"parentID":"",
				"projectLevel":0,
				"nodeType":"SYS",
				"optionMenu":1
			},
		</silk:If>
		<silk:If renderIf="admin,architect one-in ${developerRole}" >
			{
				"silkProjectID":"SYS01",
				"projectName":"System Setup",
				"parentID":"SYSROOT",
				"projectLevel":1,
				"nodeType":"INFO",
				"editor":91,
				"editRights":1,
				"_iconEmpty":"fa-solid fa-screwdriver-wrench",
				"_iconEmptyColor":"#98c32c",
				"optionMenu":1
			},
		</silk:If>
		<silk:If renderIf="read!=${developerRole}" >
			{
				"silkProjectID":"SYS02",
				"projectName":"Testing Session",
				"parentID":"SYSROOT",
				"projectLevel":1,
				"nodeType":"SESV",
				"editor":92,
				"editRights":1,
				"_iconEmpty":"fa-solid fa-flask-vial",
				"_iconEmptyColor":"#98c32c",
				"optionMenu":1
			},
			{
				"silkProjectID":"SYS03",
				"projectName":"Application Variables",
				"parentID":"SYSROOT",
				"projectLevel":1,
				"nodeType":"VAR",
				"editor":93,
				"editRights":1,
				"_iconEmpty":"fa-solid fa-clipboard-list",
				"_iconEmptyColor":"#98c32c",
				"optionMenu":1
			},
		</silk:If>
		<silk:If renderIf="admin,architect one-in ${developerRole}" >
			{
				"silkProjectID":"SYS04",
				"projectName":"Themes & Scaffolding",
				"parentID":"SYSROOT",
				"projectLevel":1,
				"nodeType":"THEM",
				"editor":94,
				"editRights":1,
				"_iconEmpty":"fa-solid fa-paint-roller",
				"_iconEmptyColor":"#98c32c",
				"optionMenu":1
			}
		</silk:If>
	</silk:DataProvider>
	
   	<silk:Button id="optionsBt" icon="fa-solid fa-gear fa-lg" dock="right" groupClass="dropstart" >
		<silk:ButtonItem id="openSystemBt" icon="fa-solid fa-arrow-up-right-from-square" label="Open Menu Page" />
		<silk:ButtonItem id="openSyncBt" icon="fa-solid fa-arrows-rotate" label="Sync Code" targetPage="syncModal" renderIf="admin,architect one-in ${developerRole}" />
		<silk:ButtonItem id="rebuildBt" icon="fa-solid fa-arrow-rotate-right" renderIf="admin, architect one-in ${developerRole}" label="Rebuild Project Files" />
	</silk:Button>

	<silk:JQcode>
		structureListPage.$page.find('.silk-navbar-right').prepend(optionsBt.$button.parent());
		optionsBt.$button.addClass('silk-navbar-button');
		optionsBt.$button.addClass('btn-link');
		optionsBt.$button.removeClass('dropdown-toggle');
		optionsBt.$button.removeClass('btn-primary');
	</silk:JQcode>
	
</silk:Module >