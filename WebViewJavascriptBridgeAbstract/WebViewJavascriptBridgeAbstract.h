#define kMessageSeparator     @"__WVJB_MESSAGE_SEPERATOR__"
#define kCustomProtocolScheme @"wvjbscheme"
#define kQueueHasMessage      @"__WVJB_QUEUE_MESSAGE__"

#if TARGET_OS_IPHONE && defined(__IPHONE_5_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0)
    #define WEAK_FALLBACK weak
#elif TARGET_OS_MAC && defined(__MAC_10_7) && (__MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_7)
    #define WEAK_FALLBACK weak
#else
    #define WEAK_FALLBACK unsafe_unretained
#endif

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@interface WebViewJavascriptBridgeAbstract : NSObject

@property (nonatomic, WEAK_FALLBACK) id webView;
@property (nonatomic, WEAK_FALLBACK) id webViewDelegate;
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
