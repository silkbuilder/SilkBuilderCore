<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
    <silk:TabItem title="MFA" >

		<h5 class="my-2" >Multi-factor Authentication</h5>
		
		<div class="alert alert-warning my-2" role="alert" >
			<i class="fas fa-exclamation-triangle"></i>
			You can configure how to receive your authentication token here.
			Email is the default method.
			Alternatively, you can use the authentication app of your choice.
		</div>

		<silk:Form id="mfaForm" dataSource="developerDP" >
			<silk:Input id="mfaType" type="select" label="Type" dataSource="mfaDP" valueColumn="value" />
			<silk:Input id="accountID" type="hidden" value="${silkUserID}" />
		</silk:Form>
		
		<div id="mfaTotpBox" class="silk-hidden" >
			<silk:Button id="setAppBt" icon="fas fa-qrcode" label="Activate Authenticator App"
				confirmTitle="Activate Authenticator App"
				confirmMessage="You will need access to an authenticator app to scan the activation QR code and get the one-time authentication token."
				confirmIcon="warning"
				confirmLabel="Continue"
			/>
			<div id="mfaActicationBox" class="silk-hidden">
				<hr/>
				<h5>Setting Authenticator App</h5>
				<ol>
					<li>Open the authenticator app in your mobile device, or install an authenticator app in your mobile device.</li>
					<li>
						Scan the following QR code in your authenticator app.<br/>
						<img id="totpQR" src="" style="width:350px;" />
					</li>
					<li>
						Enter the authentication token from your authentication app and submit.<br/>
						<silk:Input id="totpToken" type="text" mode="true" width="100px" />
						<silk:Button id="totpSubmitBt" label="Submit" />
					</li>
				</ol>
			</div>
		</div>
		
		<div id="mfaEmailBox" class="silk-hidden" >
			<silk:Button id="setEmailBt" icon="delete" label="Remove Authenticator App"
				confirmTitle="Remove Authenticator App"
				confirmMessage="This action will remove the One-Time Authentication Token and set the authentication process for sending tokens by email."
				confirmIcon="warning"
				confirmLabel="Continue"
			/>
		</div>
		
	</silk:TabItem>

	<silk:DataProvider id="mfaDP" >
		0:Email Token
		1:One-Time Token - Authenticator App
	</silk:DataProvider>

	<silk:JQcode>
		
		developerDP.on("afterSelect", function(){
			$("#mfaTotpBox").toggle( developerDP.getItem().mfaType==0 );
			$("#mfaEmailBox").toggle( developerDP.getItem().mfaType==1 );
			setAppBt.toggle( developerDP.getItem().mfaType==0 );
			$("#mfaActicationBox").hide();
			$("#totpQR").attr("src", "");
		});

		setAppBt.on("click", function(){
			postToService("{contextPath}/service/SilkBuilderIDE/profile/setTotp", {}, function(result,response){
				if( result ){
					setAppBt.hide();
					$("#mfaActicationBox").show();
					$("#totpQR").attr("src", response.qr64);
					console.log(response);
				}else{
					silk.alert("TOTP Error", "Error requesting QR code.", "error");
				}
			});
		});

		totpSubmitBt.on("click", function(){
			
			if( totpToken.getValue()=="" ){
				silk.alert("Token No Provided", "Enter the token value before submitting.", "error");
				return;
			}

			postToService("{contextPath}/service/SilkBuilderIDE/profile/setTotp", {token:totpToken.getValue()}, function(result,response){
				if( result ){
					if( response.action==1 ){
						developerDP.select();
						silk.alert("Token Accepted", "Your Authentication App has been set.", "success");
					}else{
						totpToken.setValue("");
						silk.alert("Incorrect Token", "Enter a new token value", "error");
					}
				}else{
					silk.alert("MFA Token Error", "Error setting MFA token.", "error");
				}
			});
			
		});
		
		setEmailBt.on("click", function(){
			developerDP.exec("setEmailToken");
			silk.alert("Email Token", "The authentication token will be delivered to your email account.", "success");
		});
		
		developerDP.on("afterExec", function(){
			developerDP.select();
		})

		
	</silk:JQcode>
	
</silk:Module >
