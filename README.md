WebViewJavascriptBridge
=======================
Cross-platform WebViewJavascriptBridge for HTML/Android/Chrome Extension, the javascript interface compatible with [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) 

Chrome
----------
To use a WebViewJavascriptBridge in your chrome extension:

1) Add "bridgeClientChrome.js" and "bridgeServerChrome.js" to your manifest.json  

	"content_scripts": [
		{
		"matches": ["*://*/*"],
		"js": ["user_client.js","bridgeClientChrome.js"]
		}
	],
	"background": {
		"scripts": ["bridgeServerChrome.js","user_server.js"]
	},
2) Set up the background side:

	console.log("user_server.js called!");
	bridge.sinit(function(data,responseCallback){
		console.log("Received message from javascript: "+data);
	    responseCallback("Right back atcha");
	})
	
	bridge.ssend("Well hello there");
	bridge.ssend("Give me a response, will you?", function(responseData) {
	    console.log("Background got its response! "+responseData);
	})

3) Set up the foreground side:

	console.log("user_client.js called!");
	document.addEventListener('WebViewJavascriptBridgeReady', function onBridgeReady(event) {
		var bridge = event.bridge
		bridge.init(function(message, responseCallback) {
			alert('Received message: ' + message)   
			if (responseCallback) {
				responseCallback("Right back atcha")
			}
		})
		bridge.send('Hello from the javascript')
		bridge.send('Please respond to this', function responseCallback(responseData) {
			console.log("Javascript got its response", responseData)
		})
	}, false)

	
IOS
----------
An iOS/OSX bridge for sending messages between Obj-C and JavaScript in UIWebViews/WebViews.

Coming from [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge).

