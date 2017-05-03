test:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge \
		-destination 'platform=iOS Simulator,name=iPhone 7'
	xcodebuild test -workspace Example\ Apps/ExampleSwiftApp-iOS/ExampleSwiftApp-iOS.xcworkspace -scheme ExampleSwiftApp-iOS \
		-destination 'platform=iOS Simulator,name=iPhone 7'

test-travis-ci:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge \
		-destination 'platform=iOS Simulator,name=iPhone 5s,OS=8.4'  \
		-destination 'platform=iOS Simulator,name=iPhone 6s,OS=9.3'  \
		-destination 'platform=iOS Simulator,name=iPhone 7,OS=10.1'

publish-pod:
	# pod trunk register narcvs@gmail.com 'Marcus Westin' --description='MBA/MBP-xyz'
	# First, bump podspec version, then commit & create tag: `git tag -a "v5.X.Y" -m "Tag v5.X.Y" && git push --tags`
	pod trunk push --verbose WebViewJavascriptBridge.podspec
