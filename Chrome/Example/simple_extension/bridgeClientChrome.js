(function(){
	var messageHandlers = {};
	var _messageHandler;
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
	bridge.send=function(data,responseCallback){
		var msg={"data":data};
		assert(!responseCallback || responseCallback instanceof Function,"responseCallback should be function");
		if(responseCallback){
			chrome.extension.sendMessage(msg,responseCallback)
		}else{
			chrome.extension.sendMessage(msg)
		}
	};
	bridge.init=function(onMessageCallback){
		_messageHandler=onMessageCallback;
		var adapter=onMessageCallbackAdapter();
		chrome.extension.onMessage.addListener(adapter);
		//register for accept message
		chrome.extension.sendMessage(MSG_REGISTER_WANJUAN_INTERFACE);
	}
	function onMessageCallbackAdapter(){
		var adapter=function(message, sender, sendResponse){
			_dispatchMessage(message,sendResponse);	
		}
		return adapter;
	}
	bridge.registerHandler=function(handlerName, handler) {
		messageHandlers[handlerName] = handler
	}
	
	bridge.callHandler=function(handlerName, data, responseCallback) {
		bridge.send({ handlerName:handlerName, data:data }, responseCallback)
	}

	function _dispatchMessage(message, responseCallback) {
		var handler = _messageHandler;
		if (message.handlerName) {
			handler = messageHandlers[message.handlerName]
		}
		try {
			handler(message.data, responseCallback)
		} catch(exception) {
			if (typeof console != 'undefined') {
				console.log("WebViewJavascriptBridge: WARNING: javascript handler threw.", message, exception)
			}
		}
	}	
	//dispatch event
	var event = new CustomEvent('WebViewJavascriptBridgeReady');
	event.bridge=bridge;
	document.dispatchEvent(event);
})()
