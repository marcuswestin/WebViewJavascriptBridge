#define kMessageSeparator     @"__WVJB_MESSAGE_SEPERATOR__"
#define kCustomProtocolScheme @"wvjbscheme"
#define kQueueHasMessage      @"__WVJB_QUEUE_MESSAGE__"

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@interface WebViewJavascriptBridgeAbstract : NSObject

@property (nonatomic, strong) id webView;
@property (nonatomic, strong) id webViewDelegate;
@property (nonatomic, strong) NSMutableArray *startupMessageQueue;
@property (nonatomic, strong) NSMutableDictionary *responseCallbacks;
@property (nonatomic, strong) NSMutableDictionary *messageHandlers;
@property (atomic, assign) long uniqueId;
@property (nonatomic, copy) WVJBHandler messageHandler;

+ (void)enableLogging;
- (void)send:(id)message;
- (void)send:(id)message responseCallback:(WVJBResponseCallback)responseCallback;
- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;

@end

@interface WebViewJavascriptBridgeAbstract (Protected)

- (void)_flushMessageQueue;
- (void)_sendData:(NSDictionary*)data responseCallback:(WVJBResponseCallback)responseCallback handlerName:(NSString*)handlerName;
- (void)_queueMessage:(NSDictionary*)message;
- (void)_dispatchMessage:(NSDictionary*)message;
- (NSString*)_serializeMessage:(NSDictionary*)message;
- (NSDictionary*)_deserializeMessageJSON:(NSString*)messageJSON;
- (void)_log:(NSString*)type json:(NSString*)output;

@end
