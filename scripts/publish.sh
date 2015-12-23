set -e
cd $(cd `dirname ${BASH_SOURCE[0]}` && pwd -P)
cd ..

# pod trunk register narcvs@gmail.com 'Marcus Westin' --description='MBA/MBP-xyz'
pod trunk push --allow-warnings --verbose WebViewJavascriptBridge.podspec
echo "WVJB publish.sh TODO: Remove --allow-warnings"