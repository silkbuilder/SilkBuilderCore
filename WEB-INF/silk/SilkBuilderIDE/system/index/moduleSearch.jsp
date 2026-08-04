<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >

	<silk:Page id="searchListPage" stage="A3"
		smLayout="A3:*:b"
		mdLayout="A3:*:b"
		rgLayout="A3:300px:b,B1"
		lgLayout="A3:400px:b,B1"
		xlLayout="A3:400px:b,B1"
		xxLayout="A3:500px:b,B1"
	>
		<silk:Header>
			Code Search
		</silk:Header>
		<silk:Content>
			<silk:Table id="searchList" dataSource="searchDP" cssClass="table-hover no-border" header="none" searchable="true" dpSearch="true" >
				<silk:Column>
					<span class='{iconName}' aria-hidden='true' style='color:{iconColor};' ></span>
					{projectName}&nbsp;
					<silk:If renderIf="read!=${developerRole}" >
						<a href="javascript:void(0)" onClick="runApp('{silkProjectID}')" keepIf="('APP,PUB,CSF,CSFP,MCP').indexOf('{nodeType}')!=-1" >
							<i class="fa-solid fa-circle-play fa-lg" style="color:#C6FE3A;"></i>
						</a>
					</silk:If>
				</silk:Column>
				<silk:Column align="right" renderer="editIconCode" width="30px" ></silk:Column>
				<silk:TableEmpty>
					No Records Found
				</silk:TableEmpty>
			</silk:Table>
		</silk:Content>
	</silk:Page>

	<silk:DataProvider id="searchDP" servicePath="/SilkBuilderIDE/system/ProjectOutlet" selectName="contentSearch" autoLoad="false" />
	
	<silk:JScode>
	
	</silk:JScode>
	
	<silk:JQcode>
		
		searchDP.on("beforeSelect",function(){
			let search = searchList.getSearchText();
			
			if( search=="" ){
				searchDP.clean();
				return false;
			}
			
			this.setParameter("silkSystemID",silkSystemID);
			this.setParameter("search",searchList.getSearchText());
			
			<silk:If renderIf="admin in ${developerRole}" >
				this.setParameter("role","admin");
			</silk:If>
			<silk:If renderIf="architect in ${developerRole}" >
				this.setParameter("role","architect");
			</silk:If>
			<silk:If renderIf="developer in ${developerRole}" >
				this.setParameter("role","developer");
			</silk:If>
			<silk:If renderIf="read in ${developerRole}" >
				this.setParameter("role","read");
			</silk:If>
		});

		searchList.on("click",function(col, index, realClick, ev){
			if( col==1 ){
				openTab( searchList.getSelectedItem() );
			}
		});
	</silk:JQcode>

</silk:Module >