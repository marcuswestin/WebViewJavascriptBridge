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
	bridge.ssend=function(data,responseCallback){
		var msg={"data":data};
		assert(!responseCallback || responseCallback instanceof Function,"responseCallback should be function");
		//broadcast msg
			for(var tabId in bridge.tabIds){
				chrome.tabs.sendMessage(bridge.tabIds[tabId], msg, responseCallback);
			}
		}
	bridge.sinit=function(onMessageCallback){
		_messageHandler=onMessageCallback;
		var adapter=onMessageCallbackAdapter();
		chrome.extension.onMessage.addListener(adapter);
	}
	function onMessageCallbackAdapter(){
		var adapter= function(message, sender, sendResponse){
			_dispatchMessage(message,sendResponse);
		};
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
	//register
	var register=function (message, sender, sendResponse){
		if(MSG_REGISTER_WANJUAN_INTERFACE==message && !bridge.tabIds[sender.tab]){
			bridge.tabIds[sender.tab.id]=sender.tab.id;
			console.log("regiseter:"+sender.tab.id);
		}
	}
	chrome.extension.onMessage.addListener(register);

