;(function() {
	if (window.WebViewJavascriptBridge) { return }

	var messageHandlers = {}
	var responseCallbacks = {}
	var uniqueId = 1

	function init(messageHandler) {
		if (WebViewJavascriptBridge._messageHandler) { throw new Error('WebViewJavascriptBridge.init called twice') }
		WebViewJavascriptBridge._messageHandler = messageHandler
	}

	function send(data, responseCallback) {
		_doSend({ data:data }, responseCallback)
	}
	
	function registerHandler(handlerName, handler) {
		messageHandlers[handlerName] = handler
	}
	
	function callHandler(handlerName, data, responseCallback) {
		_doSend({ handlerName:handlerName, data:data }, responseCallback)
	}
	
	function _doSend(message, responseCallback) {
		if (responseCallback) {
			var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime()
			responseCallbacks[callbackId] = responseCallback
			message['callbackId'] = callbackId
			_WebViewJavascriptBridge._handleMessageFromJs(message.data,message.responseId,
                                     message.responseData,message.callbackId,message.handlerName);
		}
	}

	function _dispatchMessageFromJAVA(messageJSON) {
			var message = JSON.parse(messageJSON)
			var messageHandler
			
			if (message.responseId) {
				var responseCallback = responseCallbacks[message.responseId]
				if (!responseCallback) { return; }
				responseCallback(message.responseData)
				delete responseCallbacks[message.responseId]
			} else {
				var responseCallback
				if (message.callbackId) {
					var callbackResponseId = message.callbackId
					responseCallback = function(responseData) {
						_doSend({ responseId:callbackResponseId, responseData:responseData })
					}
				}
				
				var handler = WebViewJavascriptBridge._messageHandler
				if (message.handlerName) {
					handler = messageHandlers[message.handlerName]
				}
				
				try {
					handler(message.data, responseCallback)
				} catch(exception) {
					if (typeof console != 'undefined') {
						console.log("WebViewJavascriptBridge: WARNING: javascript handler threw.", message, exception)
					}m
				}
			}
	}
			

	function _handleMessageFromJava(messageJSON) {
		_dispatchMessageFromJava(messageJSON)
	}

	//export
	window.WebViewJavascriptBridge = {
		init: init,
		send: send,
		registerHandler: registerHandler,
		callHandler: callHandler,
		_handleMessageFromJava: _handleMessageFromJava
	}

	//dispatch event
	var readyEvent=new CustomEvent('WebViewJavascriptBridgeReady')
	readyEvent.bridge=WebViewJavascriptBridge;
	document.dispatchEvent(readyEvent);
})();