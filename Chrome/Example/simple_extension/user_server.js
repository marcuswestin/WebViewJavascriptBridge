console.log("user_server.js called!");
bridge.sinit(function(data,responseCallback){
	console.log("Received message from javascript: "+data);
    responseCallback("Right back atcha");
})

function serverSend(){
	bridge.ssend("Well hello there");
	bridge.ssend("Give me a response, will you?", function(responseData) {
	    console.log("Background got its response! "+responseData);
	})
	bridge.callHandler("showAlert","42",function(responseData){
        console.log("got alert response:"+responseData);
	});
}

bridge.registerHandler("handler1", function(data,responseCallback) 
	{ console.log("handler1:"+data);responseCallback("back from handerl1") });

