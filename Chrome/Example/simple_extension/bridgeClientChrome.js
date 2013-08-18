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

	chrome.extension.onMessage.addListener(
		function(message, sender, sendResponse){
			_dispatchMessage(message,sendResponse);	
		});

	bridge.send=function(data,responseCallback){
		_send({"data":data},responseCallback);
	}
	function _send(msg,responseCallback){
		assert(!responseCallback || responseCallback instanceof Function,"responseCallback should be function");
		if(responseCallback){
			chrome.extension.sendMessage(msg,responseCallback)
		}else{
			chrome.extension.sendMessage(msg)
		}
	}
	bridge.init=function(onMessageCallback){
		_messageHandler=onMessageCallback;
		//register for accept message
		chrome.extension.sendMessage(MSG_REGISTER_WANJUAN_INTERFACE);
	}

	bridge.registerHandler=function(handlerName, handler) {
		messageHandlers[handlerName] = handler
	}
	
	bridge.callHandler=function(handlerName, data, responseCallback) {
		_send({ handlerName:handlerName, data:data }, responseCallback)
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
