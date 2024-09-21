// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "WebViewJavascriptBridge",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "WKWebViewJavascriptBridge",
            targets: ["WKWebViewJavascriptBridge"]
        ),
    ],
    targets: [
        .target(
            name: "WKWebViewJavascriptBridge",
            path: "WebViewJavascriptBridge",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("."),
                .define("WKWEBVIEWJAVASCRIPTBRIDGE_MODULE", to: nil)
            ]
        )
    ]
)
