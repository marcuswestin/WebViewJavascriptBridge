test:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge -destination 'platform=iOS Simulator,name=iPhone 5s'

publish-pod:
	# pod trunk register narcvs@gmail.com 'Marcus Westin' --description='MBA/MBP-xyz'
	pod trunk push --verbose WebViewJavascriptBridge.podspec
