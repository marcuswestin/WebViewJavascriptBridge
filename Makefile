test:
	brew install xctool || true
	xctool -project Tests/WebViewJavascriptBridge.xcodeproj -scheme WebViewJavascriptBridge -configuration Release -sdk iphonesimulator test

publish-pod:
	# pod trunk register narcvs@gmail.com 'Marcus Westin' --description='MBA/MBP-xyz'
	pod trunk push --allow-warnings --verbose WebViewJavascriptBridge.podspec
