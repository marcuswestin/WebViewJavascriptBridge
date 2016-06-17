;(function () {
    if (window.WebViewJavascriptBridge) {
        return;
    }
    window.WebViewJavascriptBridge = {
        registerHandler: registerHandler,
        callHandler: callHandler,
        _fetchQueue: _fetchQueue,
        _handleMessageFromObjC: _handleMessageFromObjC
    };

    var messagingIframe;
    var sendMessageQueue = [];
    var messageHandlers = {};

    var CUSTOM_PROTOCOL_SCHEME = 'wvjbscheme';
    var QUEUE_HAS_MESSAGE = '__WVJB_QUEUE_MESSAGE__';

    var responseCallbacks = {};
    var uniqueId = 1;

    function registerHandler(handlerName, handler) {
        messageHandlers[handlerName] = handler;
    }

    function callHandler(handlerName, data, responseCallback) {
        if (arguments.length == 2 && typeof data == 'function') {
            responseCallback = data;
            data = null;
        }
        _doSend({handlerName: handlerName, data: data}, responseCallback);
    }

    function _doSend(message, responseCallback) {
        if (responseCallback) {
            var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
            responseCallbacks[callbackId] = responseCallback;
            message['callbackId'] = callbackId;
        }
        sendMessageQueue.push(message);
        messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE + "?timestamp=" + Date.now();
    }

    function _fetchQueue() {
        var messageQueueString = JSON.stringify(sendMessageQueue);
        sendMessageQueue = [];
        return messageQueueString;
    }

    function _dispatchMessageFromObjC(messageJSON) {
        setTimeout(function _timeoutDispatchMessageFromObjC() {
            var message = JSON.parse(messageJSON);
            var responseCallback;

            if (message.responseId) {
                responseCallback = responseCallbacks[message.responseId];
                if (!responseCallback) {
                    return;
                }
                responseCallback(message.responseData);
                delete responseCallbacks[message.responseId];
            } else {
                if (message.callbackId) {
                    var callbackResponseId = message.callbackId;
                    responseCallback = function (responseData) {
                        _doSend({responseId: callbackResponseId, responseData: responseData});
                    };
                }

                var handler = messageHandlers[message.handlerName];
                try {
                    handler(message.data, responseCallback);
                } catch (exception) {
                    console.log("WebViewJavascriptBridge: WARNING: javascript handler threw.", message, exception);
                }
                if (!handler) {
                    console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
                }
            }
        });
    }

    function _handleMessageFromObjC(messageJSON) {
        _dispatchMessageFromObjC(messageJSON);
    }

    messagingIframe = document.createElement('iframe');
    messagingIframe.style.display = 'none';
    messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
    document.documentElement.appendChild(messagingIframe);

    setTimeout(_callWVJBCallbacks, 0);
    function _callWVJBCallbacks() {
        var callbacks = window.WVJBCallbacks;
        delete window.WVJBCallbacks;
        for (var i = 0; i < callbacks.length; i++) {
            callbacks[i](WebViewJavascriptBridge);
        }
    }
})();