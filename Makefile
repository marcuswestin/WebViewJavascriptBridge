test:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge -destination 'platform=iOS Simulator,name=iPhone 5s'

publish-pod:
	# pod trunk register narcvs@gmail.com 'Marcus Westin' --description='MBA/MBP-xyz'
	# First, bump podspec version, then commit & create tag: `git tag -a "v5.0.X" -m "Tag v5.0.X" && git push --tags`
	pod trunk push --verbose WebViewJavascriptBridge.podspec
