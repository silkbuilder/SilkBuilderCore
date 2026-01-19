<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module >
	
    <silk:TabItem title="Account" >
		<silk:Button id="accountEditBt" icon="update" label="Update" cssClass="btn-sm" dock="right" />
		<silk:Form id="accountForm" dataSource="developerDP" updateBt="accountEditBt" >
			<div class="row" >
				<div class="col-md" >
					<silk:Input id="fullName" type="text" label="Full Name" />
					<silk:Input id="emailAddress" type="email" label="Email Address"
						editable="false"
						visible="!accountForm.getMode()"
						toggleList="changeEmailBt"
					/>
					<silk:Button id="changeEmailBt" label="Change Email Address" cssClass="btn-sm" dock="right" targetPage="changeEmailModal" />
				</div>
				<div class="col-md" >
					Something Extra
				</div>
			</div>
		</silk:Form>
	</silk:TabItem>

	<silk:Modal id="changeEmailModal" title="Change Email Address" >
		<p>
			This option allows you to update your account's primary email address.
			Choose it when switching to a new email or transferring account management to someone else.
		</p>
		<p>
			For security, we'll send verification emails to both your current address and the new one to confirm the change.
		</p>
		<silk:Form id="changeEmailForm" >
			<silk:Input id="targetEmailAddress" type="email" label="Target Email Address" />
			<silk:Input id="action" value="0" />
		</silk:Form>
	</silk:Modal>
	
	<silk:JQcode>

		changeEmailModal.on("beforeShow", function(){
			changeEmailForm.clean();
			changeEmailForm.setMode(true);
		});

		changeEmailForm.on("cancel", function(){
			changeEmailModal.close();
		});

		changeEmailForm.on("submit", function(){
			changeEmailForm.post("{contextPath}/link/SilkBuilderIDE/profile/changeEmail", function(result,response){
				if( result ){
					/*
					 * If the result is true, the service executed without errors.
					 */
					if( response.unique ){
						/*
						 * If unique is true the request was submitted.
						 */
						silk.alert("Request Submitted", "Email requesting authorization had been sent to the current and new email addresses.", "success");
						changeEmailModal.close();
					} else {
						/*
						 * If unique is false, the provided email already exist.
						 */
						silk.alert("Process Failed", "The provided email address have been rejected. Enter valid email address and try again.", "warning");
						changeEmailForm.clean();
					}					

				}else{
					/*
					 * If the result is false, the service request failed.
					 * The form is activated and cleaned for another try.
					 * The response object containing error details is sent to the JavaScript console.
					 * An authentication service failed message is displayed.
					 */
					changeEmailModal.close();
					silk.alert("Connection Error", "The service is not available . Try again in a few minutes.", "error");
				}
			});
		});
		
	</silk:JQcode>
	
</silk:Module >
