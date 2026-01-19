<%--
    Copyright (c) 2025 OopsClick LLC. All rights reserved.
    this work is licensed under the O'Saasy License Agreement, a copy of which can be
    found in the LICENSE file in the root directory of this project or at https://silkbuilder.com/core-license.
--%>
<silk:Module renderIf="admin, architect one-in ${developerRole}" >
	
    <silk:Modal id="syncModal" title="Sync Process" >
		<silk:Input id="silkTargetID" type="select" dataSource="targetDP" mode="true"
			labelColumn="targetURL"
		/>
		<silk:Button id="syncBt" label="Sync Code"
			confirmTitle="Syncronization Confirmation"
			confirmMessage="The code in the target host will be removed and replare with current code."
		/>

		<div id="progressBar" class="progress" role="progressbar" aria-label="Animated striped example" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">
			<div class="progress-bar progress-bar-striped progress-bar-animated bg-info" style="width: 100%"></div>
		</div>
		
		<div id="syncResult">
		</div>
	</silk:Modal>

	<silk:JQcode>

		$("#progressBar").hide();
		
		syncModal.on("beforeShow", function(){
			silkTargetID.show();
			syncBt.show();
		});
		
		syncBt.on("click", function(){
			if( projectList.getSelectedItem().sync!=1 ){
				return;
			}
			processSync();
		});

		processSync = function(){

			silkTargetID.hide();
			syncBt.hide();
			$("#progressBar").show();
			
			let silkProjectID = projectList.getSelectedItem().silkProjectID;
			if( projectList.getSelectedItem().projectLevel==0 ) silkProjectID="0";
			
			$.ajax({
			    url : "{contextPath}/service/SilkBuilderIDE/system/pushSyncCode",
			    type : "POST",
			    data : {
			        "silkSystemID" : silkSystemID,
					"silkProjectID" : silkProjectID,
					"silkTargetID" : silkTargetID.getValue(),
					"cleanProject" : (projectList.getSelectedItem().projectLevel<2) ? 1 : 0
			    },
			    dataType:'json',
			    success : function(data) {
					if( data.result==0){
						$("#syncResult").html(
							"Error Code: "+data.code+"<br>"+
							"Message: "+data.message
						);
						silk.alert(data.message, "", "error");
					}else{
						//$("#syncResult").html( data.message );
						silk.alert(data.message, "", "success");
						$("#progressBar").hide();
						syncModal.close();
					}
			    },
				error : function(request,error){
					$("#syncResult").html(
						"Code: "+request.readyState+"<br>"+
						"Message: "+request.responseText
					);
					silk.alert(request.responseText, "", "error");
				}
			});
		};
		
	</silk:JQcode>
	
</silk:Module >