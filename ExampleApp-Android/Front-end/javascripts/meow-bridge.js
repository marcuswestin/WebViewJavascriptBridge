(function (funcName, baseObj) {
    "use strict";
    // The public function name defaults to window.docReady
    // but you can modify the last line of this function to pass in a different object or method name
    // if you want to put them in a different namespace and those will be used instead of
    // window.docReady(...)
    funcName = funcName || "ready";
    baseObj = baseObj || window;
    var readyList = [];
    var readyFired = false;
    var readyEventHandlersInstalled = false;

    // call this when the document is ready
    // this function protects itself against being called more than once
    function ready() {
        if (!readyFired) {
            // this must be set to true before we start calling callbacks
            readyFired = true;
            for (var i = 0; i < readyList.length; i++) {
                // if a callback here happens to add new ready handlers,
                // the docReady() function will see that it already fired
                // and will schedule the callback to run right after
                // this event loop finishes so all handlers will still execute
                // in order and no new ones will be added to the readyList
                // while we are processing the list
                readyList[i].fn.call(window, readyList[i].ctx);
            }
            // allow any closures held by these functions to free
            readyList = [];
        }
    }

    function readyStateChange() {
        if (document.readyState === "complete") {
            ready();
        }
    }

    // This is the one public interface
    // docReady(fn, context);
    // the context argument is optional - if present, it will be passed
    // as an argument to the callback
    baseObj[funcName] = function (callback, context) {
        // if ready has already fired, then just schedule the callback
        // to fire asynchronously, but right away
        if (readyFired) {
            setTimeout(function () {
                callback(context);
            }, 1);
            return;
        } else {
            // add the function and context to the list
            readyList.push({fn: callback, ctx: context});
        }
        // if document already ready to go, schedule the ready function to run
        // IE only safe when readyState is "complete", others safe when readyState is "interactive"
        if (document.readyState === "complete" || (!document.attachEvent && document.readyState === "interactive")) {
            setTimeout(ready, 1);
        } else if (!readyEventHandlersInstalled) {
            // otherwise if we don't have event handlers installed, install them
            if (document.addEventListener) {
                // first choice is DOMContentLoaded event
                document.addEventListener("DOMContentLoaded", ready, false);
                // backup is window load event
                window.addEventListener("load", ready, false);
            } else {
                // must be IE
                document.attachEvent("onreadystatechange", readyStateChange);
                window.attachEvent("onload", ready);
            }
            readyEventHandlersInstalled = true;
        }
    }
})("ready", window);

window.Client = function () {
    var ua = navigator.userAgent;

    var system = {iOS: false, android: false};

    system.iOS = ua.indexOf("iPhone") > -1 || ua.indexOf("iPad") > -1;

    //determine iOS version
    if (navigator.platform.indexOf("Mac") == 0 && ua.indexOf("Mobile") > -1) {
        if (/CPU (?:iPhone )?OS (\d+_\d+)/.test(ua)) {
            system.iOS = parseFloat(RegExp.$1.replace("_", "."));
        } else {
            system.iOS = 2; //can’t really detect - so guess
        }
    }

    if (/Android (\d+\.\d+)/.test(ua)) {
        system.android = parseFloat(RegExp.$1);
    }

    return system;
}();

(function (root) {

    function MeowWebViewJavascriptBridge() {
        this.iOS = window.Client.iOS;
        this.android = window.Client.android;
    }

    MeowWebViewJavascriptBridge.prototype.setupWebViewJavascriptBridge = function (callback) {
        if (window.WebViewJavascriptBridge) {
            return callback(WebViewJavascriptBridge);
        }
        if (window.WVJBCallbacks) {
            return window.WVJBCallbacks.push(callback);
        }

        window.WVJBCallbacks = [callback];
        var WVJBIframe = document.createElement('iframe');
        WVJBIframe.style.display = 'none';
        WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
        document.documentElement.appendChild(WVJBIframe);
        setTimeout(function () {
            document.documentElement.removeChild(WVJBIframe)
        }, 0)
    };

    MeowWebViewJavascriptBridge.prototype.callHandler = function (handlerName, data, callback) {
        this.setupWebViewJavascriptBridge(function (bridge) {
            bridge.callHandler(handlerName, data, callback);
        });
    };

    MeowWebViewJavascriptBridge.prototype.registerHandler = function (handlerName, callback) {
        this.setupWebViewJavascriptBridge(function (bridge) {
            bridge.registerHandler(handlerName, callback);
        });
    };

    root.webViewBridge = new MeowWebViewJavascriptBridge();
})(window);