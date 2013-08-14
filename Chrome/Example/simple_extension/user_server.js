console.log("user_server.js called!");
function onMessage(message,sendResponse){
	console.log("client said:"+message);
	sendResponse("go back");
	//bridge.send("Hello from server:"+message);
	bridge.send("Hello from server:"+message,callback);
}
bridge.init(onMessage)

function callback(hello){
	console.log(hello);
}