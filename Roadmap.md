Roadmap
=======
###通过使用该库可以轻松实现JS与原生交互。

Issues
------

- [X] `make test` fails becuase the command line invocation can't find WebKit framework. Fix.
- [ ] Sometimes tests randomly fail! Race condition...
- [X] Add WKWebView support to podspec file? (#149)
- [ ] iOS8 WKWebView support? (#126)
- [ ] WKWebView issue in OSX? (#84)
- [ ] Release new version (#143, #155, #167)
- [ ] Optional alert-unsafe message speedup (PR #133, I #132)
- [ ] Swift and WKWebView (#153, #158)
- [ ] Misc fixes
	- [ ] Crash on _deserializeMessageJSON (I #159)
	- [ ] Memory leak? (I #144)
	- [ ] Pictures/_dispatchMessage queue issue? (I #137)
	- [ ] Consider making webpage reloads easier (I #134)
	- [ ] Fix use in $(document).ready (I #131)
	- [ ] Error message on missing handler (I #120)
- [ ] Pending bug repro/info
	- [ ] #123: unity3d and WebViewJavascriptBridge unrecognized selector sent to instance
	- [ ] #124: Getting an exception during _flushMessageQueue

Misc
----

- [ ] Clean up webview delegate - can we get away without passing through one now?
- [ ] Make bridge a subclass of UI/WKWebView
- [ ] Scrap UIWebView?
- [ ] Style consistency through all code
- [ ] Test pod
- [X] Fix OSX lint warnings (`pod spec lint`)
- [X] I believe `receiveMessageQueue` in JS is no longer needed, since the JS explicitly tells ObjC when to start sending messages. Remove?

v5.0.1
------

Pull requests:
- [X] Dev env / docs
	- [X] Automated tests (PR #128, I #151)
		- [X] Travis? https://github.com/integrations/feature/code
	- [X] Embed js in objc source (PR #129)
		- [X] Also fixes PR #138, I #160, I #108
	- [X] Docs for podfile installation (PR #140)
- [X] Improve API
	- [X] Remove default bridge handler - just do command/response. Remove bridge.init
- [X] Features & fixes to consider
	- [X] Message response timeout (PR #106)
	- [X] Remove or fix numRequestsLoading (PR #146, PR #157)
- [X] Net load fixes
	- [X] Fix `[webView stopLoading]` (PR #168, I #163)
	- [x] Detect offline failed requests (PR #170)
	- [X] Handle redirects (PR #172)
	- [X] Bridge never initiates without a didLoad (I #156)

Future considerations
---------------------
- [ ] Swift
	- [ ] Swift examples (I #173)
- [ ] Javascript
	- [ ] Cookie set in client is not sent (I #171)
	- [ ] Form submission error (I #169)
- [ ] React Native
	- [ ] Example app (I #162)
- [ ] New features to consider
	- [ ] Multiple handlers: pubsub (I #119)
	- [ ] Remove handlers (I #118)
- [ ] Other platforms to consider
	- [ ] Android - partly done by @fangj (#103)
	- [ ] Chrome - partly done by @fangj (#104)
	- [ ] Windows phone


Common Messages
---------------

#### Fixed in v5.x.y:

Hi!

I believe this may be fixed in v5.0.1.

When you switch to the new version, please note that the API has changed. In particular, make sure that you use the javascript setup code, as it has changed: https://github.com/marcuswestin/WebViewJavascriptBridge#usage

If you are still having trouble when using v5.0.x, feel free to reopen.

Cheers!


#### Need repro:

Hi!

Without a repro I won't be able to help you :(

If you create a PR with a failing test then I will definitely give you a hand (see https://github.com/marcuswestin/WebViewJavascriptBridge/blob/master/Tests/WebViewJavascriptBridgeTests/BridgeTests.m and https://github.com/marcuswestin/WebViewJavascriptBridge/blob/master/Tests/WebViewJavascriptBridgeTests/echo.html).

You could also create a PR with an example in `Example Apps` with the problem you're seeing in - that would definitely help me help you :)

I'll close this in the meantime since there's nothing I can do. Feel free to reopen with a repro or more information.

Cheers!
