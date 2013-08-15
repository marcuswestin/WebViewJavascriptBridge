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
	bridge.ssend=function(msg,responseCallback){
		assert(!responseCallback || responseCallback instanceof Function,"responseCallback should be function");
		//broadcast msg
			for(var tabId in bridge.tabIds){
				chrome.tabs.sendMessage(bridge.tabIds[tabId], msg, responseCallback);
			}
		}
	bridge.sinit=function(onMessageCallback){
		var adapter=onMessageCallbackAdapter(onMessageCallback);
		chrome.extension.onMessage.addListener(adapter);
	}
	function onMessageCallbackAdapter(onMessageCallback){
		var adapter= function(message, sender, sendResponse){
			onMessageCallback(message,sendResponse);
		};
		return adapter;
	}
	//register
	var register=function (message, sender, sendResponse){
		if(MSG_REGISTER_WANJUAN_INTERFACE==message && !bridge.tabIds[sender.tab]){
			bridge.tabIds[sender.tab.id]=sender.tab.id;
			console.log("regiseter:"+sender.tab.id);
		}
	}
	chrome.extension.onMessage.addListener(register);

