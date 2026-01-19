<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
	<style>
		#sampleFrame {
			border: none;
			height: 100%;
			padding: 15px;
			border-radius: 25px;
		}
		
		#samplePage .silk-content {
			padding-top: 0px;
			overflow: unset;
		}
		
	</style>
	
	<silk:Page id="samplePage" stage="C1"
		smLayout="C1:*:b"
		mdLayout="C1:*:b"
		rgLayout="A1:300px,B1:300px,C1"
		lgLayout="A1:300px,B1:300px,C1"
		xlLayout="A1:300px,B1:300px,C1"
		xxLayout="A1:300px,B1:300px,C1"
	>
		<silk:Header>
			Sample Page
		</silk:Header>
		<silk:Content>
			<iframe id="sampleFrame" width="100%" ></iframe>
		</silk:Content>
	</silk:Page>
	
	<silk:JQcode>
		
	</silk:JQcode>
	
</silk:Module>
