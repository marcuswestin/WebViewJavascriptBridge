Roadmap
=======

v4.1.6
--------

- [ ] Add WKWebView support to podspec file? (#149)
- [ ] iOS8 WKWebView support? (#126)
- [ ] WKWebView issue in OSX? (#84)
- [ ] Release new version (#143, #155, #167)

v4.1.7
------

Pull requests:
- [ ] Dev env / docs
	- [ ] Automated tests (PR #128, I #151)
		- [ ] Travis? https://github.com/integrations/feature/code
	- [ ] Embed js in objc source (PR #129)
		- [ ] Also fixes PR #138, I #160, I #108
	- [ ] Docs for podfile installation (PR #140)
- [ ] Features & fixes to consider
	- [ ] Message response timeout (PR #106)
	- [ ] Optional alert-unsafe message speedup (PR #133, I #132)
	- [ ] Remove or fix numRequestsLoading (PR #146, PR #157)
- [ ] Net load fixes
	- [ ] Fix `[webView stopLoading]` (PR #168, I #163)
	- [ ] Detect offline failed requests (PR #170)
	- [ ] Handle redirects (PR #172)
	- [ ] Bridge never initiates without a didLoad (I #156)
- [ ] Fix OSX lint warnings (`pod spec lint`)

v4.1.8
------
- [ ] Swift and WKWebView (#153, #158)
- [ ] Misc fixes
	- [ ] Crash on _deserializeMessageJSON (I #159)
	- [ ] Memory leak? (I #144)
	- [ ] Pictures/_dispatchMessage queue issue? (I #137)
	- [ ] Consider making webpage reloads easier (I #134)
	- [ ] Fix use in $(document).ready (I #131)
	- [ ] Error message on missing handler (I #120)
	
v4.2.x
------
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

Pending bug repro/info
----------------------
- [ ] #123: unity3d and WebViewJavascriptBridge unrecognized selector sent to instance
- [ ] #124: Getting an exception during _flushMessageQueue
