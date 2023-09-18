test:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge \
		-destination 'platform=iOS Simulator,name=iPhone 8'
	xcodebuild test -workspace Example\ Apps/ExampleSwiftApp-iOS/ExampleSwiftApp-iOS.xcworkspace -scheme ExampleSwiftApp-iOS \
		-destination 'platform=iOS Simulator,name=iPhone 8'

test-many:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge \
		-destination 'platform=iOS Simulator,name=iPhone 6' \
		-destination 'platform=iOS Simulator,name=iPhone 7' \
		-destination 'platform=iOS Simulator,name=iPhone 8'

test-circle-ci:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge \
		-destination 'platform=iOS Simulator,name=iPhone 13,OS=15.5'  \
		-destination 'platform=iOS Simulator,name=iPhone 14,OS=16.0'


publish-pod:
	# pod trunk register narcvs@gmail.com 'Marcus Westin' --description='MBA/MBP-xyz'
	# First, bump podspec version, then commit & create tag: `git tag -a "v5.X.Y" -m "Tag v5.X.Y" && git push --tags`
	pod trunk push --verbose WebViewJavascriptBridge.podspec
