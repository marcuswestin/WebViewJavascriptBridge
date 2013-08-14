console.log("user_client.js called!");

document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) {
    var bridge = event.bridge
    bridge.init(onMessage);

    bridge.send('Hello from client')
   
    bridge.send('Please respond to this', function responseCallback(responseData) {
        console.log("Javascript got its response", responseData)
    })

    
}, false)
function onMessage(message,sendResponse){
    console.log("client got message:"+message);
  //  sendResponse("client got");
}



 //   chrome.extension.sendMessage("abc",function(response){console.log(response)})