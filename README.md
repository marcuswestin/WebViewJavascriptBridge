WebViewJavascriptBridge
=======================
Cross-platform WebViewJavascriptBridge for HTML/Android/Chrome Extension, the javascript interface compatible with [WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge) 

TODO:

 - Use the queue ,cache the message before the client and server both inited.
 - Use the Long-lived connections instead of the Simple one-time requests, [Message Passing](https://developer.chrome.com/extensions/messaging.html#connect)

Android
----------
To use a WebViewJavascriptBridge in your Android project:

1) Add "res/raw/webviewjavascriptbridge.js" and "com/fangjian/WebViewJavascriptBridge.java" to your project

2) Set up the Android side
	
	bridge=new WebViewJavascriptBridge(this.getApplicationContext(),webView,new UserServerHandler()) ;
	
	class UserServerHandler implements WebViewJavascriptBridge.WVJBHandler{
	        @Override
	        public void handle(String data, WebViewJavascriptBridge.WVJBResponseCallback jsCallback) {
	            Log.d("test","Received message from javascript: "+ data);
	            if (null !=jsCallback) {
	                jsCallback.callback("Java said:Right back atcha");
	            }
	            bridge.send("I expect a response!",new WebViewJavascriptBridge.WVJBResponseCallback() {
	                @Override
	                public void callback(String responseData) {
	                    Log.d("test","Got response! "+responseData);
	                }
	            });
	            bridge.send("Hi");
	        }
	    }

	bridge.registerHandler("handler1",new WebViewJavascriptBridge.WVJBHandler() {
	    @Override
	    public void handle(String data, WebViewJavascriptBridge.WVJBResponseCallback jsCallback) {
	         Log.d("test","handler1 got:"+data);
	        if(null!=jsCallback){
	            jsCallback.callback("handler1 answer");
	        }
	        bridge.callHandler("showAlert","42");
	    }
	});
	
3) Set up the Javascript side

	console.log("user_client.js called!");
	document.addEventListener('WebViewJavascriptBridgeReady'
	, function(event) {
	var bridge=event.bridge;
	bridge.init(function(message, responseCallback) {
	     if (responseCallback) {
	     responseCallback("Right back atcha") ;
	     }
	}) ;
	bridge.send('Hello from the javascript');
	bridge.send('Please respond to this', function(responseData) {
	    console.log("Javascript got its response "+ responseData);
	});
	bridge.registerHandler("showAlert", function(data) { console.log("alert:"+data); });
	bridge.callHandler("handler1","gift for handler1",function(responseData){
	    console.log("got handler1 response:"+responseData);
	});
	}, false)


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

HTML
----------
To use a WebViewJavascriptBridge in your HTML page:
1) Add "bridgeServerHtml.js" and "bridgeClientHtml.js" to your page. bridgeServerHtml.js Must be first and bridgeClientHtml.js Must be last.

	<script src="bridgeServerHtml.js"></script> <!--muse be first -->
	<script src="user_client.js"></script> 
	<script src="user_server.js"></script> 
	<script src="bridgeClientHtml.js"></script>  <!--muse be last -->

2) Set up the background side:
	
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

forked from  [marcuswestin/WebViewJavascriptBridge](https://github.com/marcuswestin/WebViewJavascriptBridge).

