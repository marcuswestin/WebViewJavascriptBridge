console.log("user_server.js called!");
bridge.sinit(function(data,responseCallback){
	console.log("Received message from javascript: "+data);
	if(responseCallback){
    	responseCallback("Right back atcha");
	}
})

function serverSend(){
	bridge.ssend("Well hello there");
	bridge.ssend("Give me a response, will you?", function(responseData) {
	    console.log("Background got its response! "+responseData);
	})
}

setTimeout(serverSend,1000);
