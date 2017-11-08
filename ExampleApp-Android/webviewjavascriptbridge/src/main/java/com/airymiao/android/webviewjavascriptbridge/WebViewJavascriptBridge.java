package com.airymiao.android.webviewjavascriptbridge;

/**
 * Created by Air on 6/17/16.
 */
public class WebViewJavascriptBridge {
    public static String loadMeowBridgeJavascript() {
        return ";(function () {\n" +
                "    if (window.WebViewJavascriptBridge) {\n" +
                "        return;\n" +
                "    }\n" +
                "    window.WebViewJavascriptBridge = {\n" +
                "        registerHandler: registerHandler,\n" +
                "        callHandler: callHandler,\n" +
                "        _fetchQueue: _fetchQueue,\n" +
                "        _handleMessageFromObjC: _handleMessageFromObjC\n" +
                "    };\n" +
                "\n" +
                "    var messagingIframe;\n" +
                "    var sendMessageQueue = [];\n" +
                "    var messageHandlers = {};\n" +
                "\n" +
                "    var CUSTOM_PROTOCOL_SCHEME = 'wvjbscheme';\n" +
                "    var QUEUE_HAS_MESSAGE = '__WVJB_QUEUE_MESSAGE__';\n" +
                "\n" +
                "    var responseCallbacks = {};\n" +
                "    var uniqueId = 1;\n" +
                "\n" +
                "    function registerHandler(handlerName, handler) {\n" +
                "        messageHandlers[handlerName] = handler;\n" +
                "    }\n" +
                "\n" +
                "    function callHandler(handlerName, data, responseCallback) {\n" +
                "        if (arguments.length == 2 && typeof data == 'function') {\n" +
                "            responseCallback = data;\n" +
                "            data = null;\n" +
                "        }\n" +
                "        _doSend({handlerName: handlerName, data: data}, responseCallback);\n" +
                "    }\n" +
                "\n" +
                "    function _doSend(message, responseCallback) {\n" +
                "        if (responseCallback) {\n" +
                "            var callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();\n" +
                "            responseCallbacks[callbackId] = responseCallback;\n" +
                "            message['callbackId'] = callbackId;\n" +
                "        }\n" +
                "        sendMessageQueue.push(message);\n" +
                "        messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE + \"?timestamp=\" + Date.now();\n" +
                "    }\n" +
                "\n" +
                "    function _fetchQueue() {\n" +
                "        var messageQueueString = JSON.stringify(sendMessageQueue);\n" +
                "        sendMessageQueue = [];\n" +
                "        return messageQueueString;\n" +
                "    }\n" +
                "\n" +
                "    function _dispatchMessageFromObjC(messageJSON) {\n" +
                "        setTimeout(function _timeoutDispatchMessageFromObjC() {\n" +
                "            var message = JSON.parse(messageJSON);\n" +
                "            var responseCallback;\n" +
                "\n" +
                "            if (message.responseId) {\n" +
                "                responseCallback = responseCallbacks[message.responseId];\n" +
                "                if (!responseCallback) {\n" +
                "                    return;\n" +
                "                }\n" +
                "                responseCallback(message.responseData);\n" +
                "                delete responseCallbacks[message.responseId];\n" +
                "            } else {\n" +
                "                if (message.callbackId) {\n" +
                "                    var callbackResponseId = message.callbackId;\n" +
                "                    responseCallback = function (responseData) {\n" +
                "                        _doSend({responseId: callbackResponseId, responseData: responseData});\n" +
                "                    };\n" +
                "                }\n" +
                "\n" +
                "                var handler = messageHandlers[message.handlerName];\n" +
                "                try {\n" +
                "                    handler(message.data, responseCallback);\n" +
                "                } catch (exception) {\n" +
                "                    console.log(\"WebViewJavascriptBridge: WARNING: javascript handler threw.\", message, exception);\n" +
                "                }\n" +
                "                if (!handler) {\n" +
                "                    console.log(\"WebViewJavascriptBridge: WARNING: no handler for message from ObjC:\", message);\n" +
                "                }\n" +
                "            }\n" +
                "        });\n" +
                "    }\n" +
                "\n" +
                "    function _handleMessageFromObjC(messageJSON) {\n" +
                "        _dispatchMessageFromObjC(messageJSON);\n" +
                "    }\n" +
                "\n" +
                "    messagingIframe = document.createElement('iframe');\n" +
                "    messagingIframe.style.display = 'none';\n" +
                "    messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;\n" +
                "    document.documentElement.appendChild(messagingIframe);\n" +
                "\n" +
                "    setTimeout(_callWVJBCallbacks, 0);\n" +
                "    function _callWVJBCallbacks() {\n" +
                "        var callbacks = window.WVJBCallbacks;\n" +
                "        delete window.WVJBCallbacks;\n" +
                "        for (var i = 0; i < callbacks.length; i++) {\n" +
                "            callbacks[i](WebViewJavascriptBridge);\n" +
                "        }\n" +
                "    }\n" +
                "})();";
    }
}
