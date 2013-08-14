console.log("user_server.js called!");
bridge.init(function(data,responseCallback){
	console.log("Received message from javascript: "+data);
    responseCallback("Right back atcha");
})

bridge.send("Well hello there");
bridge.send("Give me a response, will you?", function(responseData) {
    console.log("Background got its response! "+responseData);
})