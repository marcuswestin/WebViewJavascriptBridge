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
	bridge.send=function(msg,responseCallback){
		assert(!responseCallback || responseCallback instanceof Function,"responseCallback should be function");
		//broadcast msg
		/*
			chrome.windows.getAll({"populate":true}, function (windows){
			for (var i = 0; i < windows.length; i++) {
				tabs=windows[i].tabs;
				for (var j = 0; j < tabs.length; j++) {
					
					if(!tabs[j].url.match(/^http.+/)){
						continue;
					}
					
					var tabId=tabs[j].id;
						chrome.tabs.sendMessage(tabId, msg, responseCallback);
					};
				};
			});
		*/
			for(var tabId in bridge.tabIds){
				chrome.tabs.sendMessage(bridge.tabIds[tabId], msg, responseCallback);
			}
		}
	bridge.init=function(onMessageCallback){
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

