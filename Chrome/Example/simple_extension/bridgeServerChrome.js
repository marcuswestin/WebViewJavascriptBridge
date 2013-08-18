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
	bridge.tabIds={};
	var messageHandlers = {};
	var _messageHandler;

	chrome.runtime.onMessage.addListener(
		function(message, sender, sendResponse){
			if(register(message,sender,sendResponse))return;
			_dispatchMessage(message,sendResponse);	
	});

	bridge.ssend=function(data,responseCallback){
		_send({"data":data},responseCallback);
	}
	function _send(msg,responseCallback){
		assert(!responseCallback || responseCallback instanceof Function,"responseCallback should be function");
		//broadcast msg
		for(var tabId in bridge.tabIds){
			chrome.tabs.sendMessage(bridge.tabIds[tabId], msg, responseCallback);
		}
	}

	bridge.sinit=function(onMessageCallback){
		_messageHandler=onMessageCallback;	
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
	//register
	var register=function (message, sender, sendResponse){
		if(MSG_REGISTER_WANJUAN_INTERFACE==message && !bridge.tabIds[sender.tab]){
			bridge.tabIds[sender.tab.id]=sender.tab.id;
			console.log("regiseter:"+sender.tab.id);
			return true;
		}
	}
	//chrome.extension.onMessage.addListener(register);

