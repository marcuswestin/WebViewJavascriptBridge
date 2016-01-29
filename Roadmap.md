Roadmap
=======

Issues
------

- [ ] Add WKWebView support to podspec file? (#149)
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
- [ ] Fix OSX lint warnings (`pod spec lint`)
- [ ] I believe `receiveMessageQueue` in JS is no longer needed, since the JS explicitly tells ObjC when to start sending messages. Remove?

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
