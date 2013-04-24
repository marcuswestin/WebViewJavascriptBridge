//
//  AppDelegate.h
//  ExampleApp-OSX
//
//  Created by Antoine Lagadec on 07/04/13.
//  Copyright (c) 2013 Antoine Lagadec. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WebViewJavascriptBridge_OSX.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet WebView *webView;

- (IBAction)sendMessage:(id)sender;
- (IBAction)callHandler:(id)sender;

@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

@end
