(function(){
	//common
	function assert(condition, message) {
    	if (!condition) {
        	throw message || "Assertion failed";
    	}
	}
	//const
	var MSG_REGISTER_WANJUAN_INTERFACE="MSG_REGISTER_WANJUAN_INTERFACE";
	//bridge
	var bridge = {};
	bridge.send=function(msg,responseCallback){
		assert(!responseCallback || responseCallback instanceof Function,"responseCallback should be function");
		if(responseCallback){
			chrome.extension.sendMessage(msg,responseCallback)
		}else{
			chrome.extension.sendMessage(msg)
		}
	};
	bridge.init=function(onMessageCallback){
		var adapter=onMessageCallbackAdapter(onMessageCallback);
		chrome.extension.onMessage.addListener(adapter);
		//register for accept message
		chrome.extension.sendMessage(MSG_REGISTER_WANJUAN_INTERFACE);
	}
	function onMessageCallbackAdapter(onMessageCallback){
		var adapter=function(message, sender, sendResponse){
			onMessageCallback(message,sendResponse);	
		}
		return adapter;
	}
	//dispatch event
	var event = new CustomEvent('WebViewJavascriptBridgeReady');
	event.bridge=bridge;
	document.dispatchEvent(event);
})()
