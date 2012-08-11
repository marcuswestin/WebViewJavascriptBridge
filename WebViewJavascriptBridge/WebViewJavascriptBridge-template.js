;(function() {
	if (window.WebViewJavascriptBridge) { return }
	var _readyMessageIframe,
		_sendMessageQueue = [],
		_receiveMessageQueue = [],
		_jsCallbacks = [],
		_MESSAGE_SEPERATOR = '%@',
		_CUSTOM_PROTOCOL_SCHEME = '%@',
		_QUEUE_HAS_MESSAGE = '%@',
		_CALLBACK_MESSAGE_PREFIX = '%@',
		_CALLBACK_FUNCTION_KEY = '%@',
		_CALLBACK_ARGUMENTS_KEY = '%@'

	function _createQueueReadyIframe(doc) {
		_readyMessageIframe = doc.createElement('iframe')
		_readyMessageIframe.style.display = 'none'
		doc.documentElement.appendChild(_readyMessageIframe)
	}

	function _sendMessage(message) {
		_sendMessageQueue.push(message)
		_readyMessageIframe.src = _CUSTOM_PROTOCOL_SCHEME + '://' + _QUEUE_HAS_MESSAGE
	}

	function _callObjcCallback(name, params) {
		var payload = {}
		payload[_CALLBACK_FUNCTION_KEY] = name
		payload[_CALLBACK_ARGUMENTS_KEY] = params
		_sendMessage(_CALLBACK_MESSAGE_PREFIX + JSON.stringify(payload))
	}

	function _fetchQueue() {
		var messageQueueString = _sendMessageQueue.join(_MESSAGE_SEPERATOR)
		_sendMessageQueue = []
		return messageQueueString
	}

	function _setMessageHandler(messageHandler) {
		if (WebViewJavascriptBridge._messageHandler) { return alert('WebViewJavascriptBridge.setMessageHandler called twice') }
		WebViewJavascriptBridge._messageHandler = messageHandler
		var receivedMessages = _receiveMessageQueue
		_receiveMessageQueue = null
		for (var i=0; i<receivedMessages.length; i++) {
			WebViewJavascriptBridge._dispatchMessageFromObjC(receivedMessages[i])
		}
	}

	function _registerJsCallback(name, callback) {
		_jsCallbacks[name] = callback
	}

	function _dispatchMessageFromObjC(message) {
		if (message.indexOf(_CALLBACK_MESSAGE_PREFIX) == 0) {
			var payload = message.replace(_CALLBACK_MESSAGE_PREFIX, '')
			var parsedPayload = JSON.parse(payload)
			var callbackName = parsedPayload[_CALLBACK_FUNCTION_KEY]
			var callback = _jsCallbacks[callbackName]

			if (callback) {
				callback(parsedPayload[_CALLBACK_ARGUMENTS_KEY])
			} else {
				WebViewJavascriptBridge._messageHandler(message)
			}
		} else {
			WebViewJavascriptBridge._messageHandler(message)
		}
	}

	function _handleMessageFromObjC(message) {
		if (_receiveMessageQueue) {
			_receiveMessageQueue.push(message)
		} else {
			WebViewJavascriptBridge._dispatchMessageFromObjC(message)
		}
	}

	window.WebViewJavascriptBridge = {
		setMessageHandler: _setMessageHandler,
		sendMessage: _sendMessage,
		callObjcCallback: _callObjcCallback,
		registerJsCallback: _registerJsCallback,
		_fetchQueue: _fetchQueue,
		_handleMessageFromObjC: _handleMessageFromObjC,
		_dispatchMessageFromObjC: _dispatchMessageFromObjC
	}

	var doc = document
	_createQueueReadyIframe(doc)
	var readyEvent = doc.createEvent('Events')
	readyEvent.initEvent('WebViewJavascriptBridgeReady')
	doc.dispatchEvent(readyEvent)
})();
