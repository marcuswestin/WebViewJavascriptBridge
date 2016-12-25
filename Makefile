test:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge \
		-destination 'platform=iOS Simulator,name=iPhone 7'

test-all:
	xcodebuild test -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge \
		-destination 'platform=iOS Simulator,name=iPhone SE,OS=10.1' \
		-destination 'platform=iOS Simulator,name=iPhone 6s Plus,OS=9.3'  \
		-destination 'platform=iOS Simulator,name=iPhone 5s,OS=8.4'  \
		-destination 'platform=iOS Simulator,name=iPhone 7'

publish-pod:
	# pod trunk register narcvs@gmail.com 'Marcus Westin' --description='MBA/MBP-xyz'
	# First, bump podspec version, then commit & create tag: `git tag -a "v5.0.X" -m "Tag v5.0.X" && git push --tags`
	pod trunk push --verbose WebViewJavascriptBridge.podspec
