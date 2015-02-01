//
//  SSClient.m
//  Jobs
//
//  Created by Anping Wang on 3/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSClient.h"
#import "SSJSONUtil.h"
#import "DebugLogger.h"
#import "SSStorageManager.h"
#import "SSLoginVC.h"
#import "SSClientCacheMgr.h"
#import "SSReachability.h"
#import "ObjectTypeUtil.h"
#import "ConfigurationManager.h"

@interface SSClient ()
{
    NSMutableArray *observers;
    NSString *appName;
    NSString *appKey;
    int timeout;
    SSClientCallback callbackBlock;
    NSString *context;
    //Security Stuff
    NSString *username;
    NSString *password;
    NSString *authSource;
    
    //Configuration
    NSString *baseUrl;
    
    //HTTP Stuff
    NSMutableDictionary *header;
    NSString *url;
    NSMutableData *receivedData;
    NSMutableURLRequest *request;
    NSHTTPURLResponse *httpResponse;
    BOOL challenged;
    SSCallbackEvent * event;
    SSClientCacheMgr * cacheManager;
    id cachePolicy;
    BOOL syncMode;
}

@end

@implementation SSClient

static SSReachability *hostReach;
static NSMutableDictionary *requestQueue;

+ (SSClient *) getClient
{
    return [[[[SSClient instanceForApp: [ObjectTypeUtil application].name withKey:MY_APPLICATION_KEY]
              setBaseUrl:AMAZON_END_POINT]
             setTimeout:60] setCachePolicy:@"enabled"];
}

- (void) reachabilityChanged: (NSNotification* )note
{
    hostReach = [note object];
    DebugLog(@"%d", [hostReach currentReachabilityStatus]);
}

- (BOOL) isHostReachable : (NSString *) host
{
    if (!hostReach)
    {
        hostReach = [SSReachability reachabilityWithHostName: host];
        [hostReach startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reachabilityChanged:)
                                                     name: kReachabilityChangedNotification
                                                   object: nil];
	}
   
    
    hostReach = [SSReachability reachabilityWithHostName: host];
    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    return netStatus != NotReachable;
}

//handle network status
- (BOOL) reachable
{
    BOOL reachable = [self isHostReachable:@"www.google.com"];
   
    return YES || reachable;
}

//Private methods
- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8));
    return result;
}

- (void) initEvent
{
    event = [[SSCallbackEvent alloc]init];
    event.client = self;
    event.uri = url;
    event.callerContext = context;
    event.userInfo = [[NSMutableDictionary alloc]init];
}

- (NSMutableURLRequest *) requestForGet
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    
    [urlRequest setURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    
    [urlRequest setHTTPMethod:HTTP_METHOD_GET];
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    
    urlRequest.timeoutInterval = timeout;
    return urlRequest;
}

- (NSMutableURLRequest *) requestForDelete
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod:HTTP_METHOD_DELETE];
    
    
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
  
    urlRequest.timeoutInterval = timeout;
    return urlRequest;
}

- (NSMutableURLRequest *) requestForPut:(NSDictionary *) item
{
    NSData *postData = item ? [item JSONData] : nil;
    NSString *postLength = [NSString stringWithFormat:INTEGER_FOMART, [postData length]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod: HTTP_METHOD_PUT];
    [urlRequest setValue: postLength forHTTPHeaderField: HTTP_CONTENT_LENGTH_KEY];
    [urlRequest setValue: MIME_APPLICATION_JSON forHTTPHeaderField: HTTP_CONTENT_TYPE_KEY];
    [urlRequest setHTTPBody: postData];
    urlRequest.timeoutInterval = timeout;
    
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    return urlRequest;
}

- (NSMutableURLRequest *) requestForPost:(NSDictionary *) item
{
    [self initEvent];
    NSData *postData = item ? [item JSONData] : nil;
    
    NSString *postLength = [NSString stringWithFormat:INTEGER_FOMART, [postData length]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]];
    [urlRequest setHTTPMethod: HTTP_METHOD_POST];
    [urlRequest setValue: postLength forHTTPHeaderField: HTTP_CONTENT_LENGTH_KEY];
    [urlRequest setValue: MIME_APPLICATION_JSON forHTTPHeaderField: HTTP_CONTENT_TYPE_KEY];
    [urlRequest setHTTPBody: postData];
    urlRequest.timeoutInterval = timeout;
    
    if(header && [header count] > 0)
    {
        [urlRequest setAllHTTPHeaderFields:header];
    }
    return urlRequest;
}

- (void) updateEventWithResponse:(NSURLResponse *)response
{
    httpResponse = (NSHTTPURLResponse *) response;
    NSDictionary * responseHeader = [httpResponse allHeaderFields];
    
    NSString *contentType = [responseHeader objectForKey:HTTP_CONTENT_TYPE];
    if (contentType)
    {
        NSArray *array = [contentType componentsSeparatedByString:@";"];
        event.contentType = [array objectAtIndex:0];
    }
    
    NSString *contentLength = [responseHeader objectForKey:HTTP_CONTENT_LENGTH_KEY];
    if (contentLength)
    {
        event.contentLength = [contentLength intValue];
    }
    [receivedData setLength:0];
}

//HTTP delegate
- (void)connection:(NSURLConnection *) connection didReceiveResponse:(NSURLResponse *)response
{
    [self updateEventWithResponse:response];
}

//using a delegate might be better here
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (callbackBlock)
    {
        event.callingStatus = SSEVENT_ERROR;
        event.error = [[NSError alloc] initWithDomain:@"Security" code:1001 userInfo:nil];
        callbackBlock(event);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    if (callbackBlock)
    {
        event.callingStatus = SSEVENT_IN_PROGRESS;
        event.data = receivedData;
        callbackBlock(event);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (callbackBlock)
    {
        event.callingStatus = SSEVENT_ERROR;
        event.error = error;
        callbackBlock(event);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self onConnectionSuccess];
}

- (void) onConnectionSuccess
{
    if (callbackBlock)
    {
        event.callingStatus = SSEVENT_SUCCESS;
        if ([event.contentType isEqualToString: MIME_APPLICATION_JSON])
        {
            NSError *error;
            event.responseCode = httpResponse.statusCode;
            if ([receivedData length] > 0)
            {
                NSString *jsonString = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
                NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
                if (error)
                {
                    event.callingStatus = SSEVENT_ERROR;
                    event.error = [[NSError alloc]initWithDomain:@"Server Error, please try again" code:[httpResponse statusCode] userInfo:nil];
                    
                    DebugLog(@"Received data:\n%@", jsonString);
                    
                    event.data = nil;
                }
                else
                {
                    if (event.responseCode != 200)
                    {
                        DebugLog(@"Error - %@", dic);
                        if (event.responseCode > 400)
                        {
                            event.callingStatus = SSEVENT_ERROR;
                            event.error = [[NSError alloc]initWithDomain:@"Server" code:[httpResponse statusCode] userInfo:dic];
                        }
                        else
                        {
                            NSString * serverstatus = [dic objectForKey:@"status"];
                            if (serverstatus && ([serverstatus isEqualToString:@"Severe"]))
                            {
                                event.callingStatus = SSEVENT_ERROR;
                                event.error = [[NSError alloc]initWithDomain:@"Server" code:1002 userInfo:dic];
                            }
                            else
                            {
                                event.callingStatus = SSEVENT_ERROR;
                            }
                        }
                    }
                    else
                    {
                        event.data = dic;
                        event.expired = NO;
                        event.cached = NO;
                        //DebugLog(@"Data reveived on %@\n%@", event.uri, dic);
                    }
                }
            }
        }
        else
        {
            event.data = receivedData;
        }
        
        if (!event.error && cachePolicy && event.data && !event.cached)
        {
            [cacheManager updateCache: event];
        }
        
        callbackBlock(event);
        //NSLog(@"%@\n%@", event.callerContext, event.uri);
        //incase queued up calls, call them as well and clear the queue afterwards
        if ([event.callerContext isEqualToString:@"query"]
            || [event.callerContext isEqualToString:@"download"]
            || [event.callerContext isEqualToString:@"getObject"]
            || [event.callerContext isEqualToString:@"getDefinition"]
            )
        {
            @synchronized(requestQueue)
            {
                NSArray *requests = [requestQueue objectForKey:event.uri];
                for (SSClientCallback callback in requests)
                {
                    callback(event);
                }
                [requestQueue removeObjectForKey:event.uri];
            }
        }
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"url:%@\nheader:%@\nUsername:%@", url, header, username];
}

////////////////////////////////////////////////////////

- (void) initHeader
{
    header = [[NSMutableDictionary alloc]init];
    [header setObject:MIME_APPLICATION_JSON forKey:HTTP_ACCEPT];
    if (username)
    {
        NSString *usernamepassword = [NSString stringWithFormat:@"%@:%@", username, password];
        [header setObject:[NSString stringWithFormat:@"Basic %@", [usernamepassword toBase64]] forKey:SECURITY_AUTHENTICATION];
        [header setObject:authSource ?  authSource : @"sixstreams.com" forKey:SECURITY_REQUEST_SOURCE_KEY];
    }
    
    [header setObject:MIME_APPLICATION_JSON forKey:HTTP_CONTENT_TYPE];
    [header setObject:appKey forKey:APPLICATION_KEY_HEADER_KEY];
    [header setObject:appName forKey:APPLICATION_ID_HEADER_KEY];
    [self initEvent];
}

- (void) initCall:(NSString *) ctx
{
    context= ctx;
    username = [SSLoginVC getUsername];
    password = [SSLoginVC getPassword];
    authSource = [SSLoginVC getAuthSource];
    [self initHeader];
    
}

//Public API
- (void) signup : (NSString *) userid
        password: (NSString *) pwd
        email: (NSString *) email
     oAuthSource:(NSString *)oAuthSource
        profile : (id) profile
      onCallback: (SSClientCallback) callback
{
    context = CONTEXT_SINGUP;
    authSource = oAuthSource ? oAuthSource : @"sixstreams.com";
    callbackBlock = callback;
    username = userid;
    password = pwd;
    NSMutableDictionary *person = [NSMutableDictionary dictionaryWithDictionary:profile];
    
    [person setValue:email forKey:EMAIL];
    [person setValue:userid forKey:USERNAME];
    [person setValue:authSource forKey:OAUTH_SOURCE];
    [person setValue:password forKey:PASSWORD];
    
    [self initHeader];
    
    [header setObject: CONTEXT_SINGUP forKey: SECURITY_REQUEST_HEADER_KEY];
    [header setObject: authSource forKey: SECURITY_REQUEST_SOURCE_KEY];
    
    url = [NSString stringWithFormat:URL_COLLECTION_FORMAT, baseUrl, USER_TYPE];
    event.uri = url;
    if ([self reachable] && [[NSURLConnection alloc] initWithRequest:[self requestForPost:person] delegate:self])
    {
        receivedData = [NSMutableData data];
    }
}

- (void) removeAccount: (NSString *) user
              password: (NSString *) pwd
           oAuthSource: (NSString *)oAuthSource
            onCallback: (SSClientCallback) callback
{
    context = CONTEXT_DELETE_ACCOUNT;
    callbackBlock = callback;
    username = user;
    password = pwd;
    authSource = oAuthSource ? oAuthSource : @"sixstreams.com";;
    [self initHeader];
    
    [header setObject: CONTEXT_DELETE_ACCOUNT forKey: SECURITY_REQUEST_HEADER_KEY];
    
    url = [NSString stringWithFormat:URL_COLLECTION_FORMAT, baseUrl, USER_TYPE];
    event.uri = url;
    if ([self reachable] && [[NSURLConnection alloc] initWithRequest:[self requestForDelete] delegate:self])
    {
        receivedData = [NSMutableData data];
    }
}

- (void) login: (NSString *) user
      password: (NSString *) pwd
   oAuthSource: (NSString *) oAuthSource
    onCallback: (SSClientCallback) callback
{
    context = CONTEXT_LOGIN;
    callbackBlock = callback;
    username = user;
    password = pwd;
    authSource = oAuthSource ? oAuthSource : @"sixstreams.com";;
    [self initHeader];
    
    [header setObject: CONTEXT_LOGIN forKey: SECURITY_REQUEST_HEADER_KEY];
    url = [NSString stringWithFormat:URL_COLLECTION_FORMAT, baseUrl, USER_TYPE];
    event.uri = url;
    
    if ([self reachable] && [[NSURLConnection alloc] initWithRequest:[self requestForGet] delegate:self])
    {
        receivedData = [NSMutableData data];
    }
}

//remove local login status. server does not keep session

- (NSData *) download: (NSString *)type
           onCallback: (SSClientCallback) callback
{
    [self initCall:@"download"];
    url = [NSString stringWithFormat:URL_COLLECTION_FORMAT, baseUrl, type];
    callbackBlock = callback;
    event.uri = url;

    event.cachedEvent = [cacheManager cachedEvent: url ofType: type];
    
    //handle multiple request on the same url
    if ([self queueRequest:url callback:callback])
    {
        callbackBlock = nil;
        return event.cachedEvent.data;
    }
    
    if ([self reachable] && [[NSURLConnection alloc] initWithRequest:[self requestForGet] delegate:self])
    {
        event.objectType = type;
        receivedData = [NSMutableData data];
    }

    if (event.cachedEvent.data)
    {
        return event.cachedEvent.data;
    }
    else
    {
        DebugLog(@"Not cached %@", event.uri);
    }
    
    return nil;
}

- (BOOL) upload: (NSString *) type
           data: (NSData *) data2Upload
       iconData: (NSData *) iconData
   withMetaData: (NSDictionary *) metadata
     onCallback: (SSClientCallback) callback
{
    [self initCall:@"upload"];
    callbackBlock = callback;
    
    NSMutableData *theBodyData = [NSMutableData data];
    [theBodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", _BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[@"Content-Disposition: form-data; name= \"item\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[[NSString stringWithFormat:@"%@", [metadata JSONString]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [theBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", _BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *filename = [metadata objectForKey:@"name"];
    [theBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", filename, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [metadata objectForKey:@"contentType"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData: data2Upload];
    [theBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", _BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *iconName = @"icon";
    [theBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", iconName, iconName] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [metadata objectForKey:@"contentType"]] dataUsingEncoding:NSUTF8StringEncoding]];
    [theBodyData appendData: iconData];
    [theBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", _BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [header setObject:[NSString stringWithFormat:_BOUNDARY_FORMAT, _BOUNDARY] forKey:HTTP_CONTENT_TYPE_KEY];
    [header setObject:[NSString stringWithFormat:INTEGER_FOMART, [theBodyData length]] forKey:HTTP_CONTENT_LENGTH_KEY];
    
    url = [NSString stringWithFormat:URL_COLLECTION_FORMAT, baseUrl, type];
    event.uri = url;
    request = [self requestForPost:nil];
    [request setHTTPBody: theBodyData];
    
    if ([[NSURLConnection alloc] initWithRequest:request delegate:self])
    {
        event.objectType = type;
        receivedData = [NSMutableData data];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) createObject: (id) object
               ofType: (NSString *) type
           onCallback: (SSClientCallback) callback
{
    [self initCall:@"createObject"];
    callbackBlock = callback;
    url = [NSString stringWithFormat:URL_COLLECTION_FORMAT, baseUrl, type];
    event.uri = url;

    event.objectType = type;
    [self connect:[self requestForPost:object]];
}

- (void) updateObject:(id) object
               ofType:(NSString *)type
           onCallback:(SSClientCallback) callback
{
    [self initCall:@"updateObject"];
    callbackBlock = callback;
    url = [NSString stringWithFormat:URL_ENTITY_FORMAT, baseUrl, type, [object objectForKey:@"id"]];
    event.uri = url;

    event.objectType = type;
    
    
    //[self connect:[self requestForPut:object]];
}

- (void) deleteObject:(NSString *) objectId
               ofType:(NSString *) type
           onCallback:(SSClientCallback) callback
{
    [self initCall:@"deleteObject"];
    callbackBlock = callback;
    url = [NSString stringWithFormat:URL_ENTITY_FORMAT, baseUrl, type, objectId];
    event.uri = url;

    event.objectType = type;
    
    //[self connect:[self requestForDelete]];
}

- (SSCallbackEvent *) getJsonObjectAt:(NSString *) urlStr
                      onCallback:(SSClientCallback) callback
{
    [self initCall:@"getObject"];
    url = urlStr;
    event.uri = urlStr;
    callbackBlock = callback;
    event.cachedEvent = [cacheManager cachedEvent: url ofType: nil];
    event.objectType = nil;

    if ([self queueRequest:url callback:callback])
    {
        return event.cachedEvent;
    }
    
    //[self connect:[self requestForGet]];
    return event.cachedEvent;
}

- (SSCallbackEvent *) getObject:(NSString *) objectId
            ofType:(NSString *) type
        onCallback:(SSClientCallback) callback
{
    [self initCall:@"getObject"];
    url = [NSString stringWithFormat:URL_ENTITY_FORMAT, baseUrl, type, objectId];
    event.uri = url;
    
    callbackBlock = callback;
   
    event.cachedEvent = [cacheManager cachedEvent: url ofType: type];
    event.objectType = type;
    //before we connect, we need check if the same url is being requested, if yes
    //we will queue it up
    if ([self queueRequest:url callback:callback])
    {
        return event.cachedEvent;
    }
    //[self connect:[self requestForGet]];
    return event.cachedEvent;
}

- (void) connect:(NSMutableURLRequest *) httpRequest
{
    if (!syncMode)
    {
        if ([self reachable] && [[NSURLConnection alloc] initWithRequest:httpRequest delegate:self])
        {
            receivedData = [NSMutableData data];
        }
        else
        {
            event.callingStatus = SSEVENT_ERROR;
            event.error = [[NSError alloc]initWithDomain: @"Connection"
                                                    code: 401
                                                userInfo: [[NSDictionary alloc] initWithObjectsAndKeys:@"Network is not reachable",@"message", nil]
                           ];
            callbackBlock(event);
        }
    }
    else
    {
        if ([self reachable])
        {
            NSError *error;
            NSURLResponse *response;
            NSData *httpData = [NSURLConnection sendSynchronousRequest: httpRequest
                                                     returningResponse: &response
                                                                 error: &error];
            
            receivedData = [[NSMutableData alloc]init];
            
            [self updateEventWithResponse:response];
            [receivedData setData:httpData];
            if (error)
            {
                event.callingStatus = SSEVENT_ERROR;
                event.error = error;
                callbackBlock(event);
            }
            else
            {
                [self onConnectionSuccess];
            }
        }
        else
        {
            if (event.cachedEvent)
            {
                event.callingStatus = SSEVENT_ERROR;
                event.error = [[NSError alloc]initWithDomain: @"Connection"
                                                        code: 401
                                                    userInfo: [[NSDictionary alloc] initWithObjectsAndKeys:@"Network is not reachable", @"message", nil]
                               ];
                callbackBlock(event);
            }
        }
    }
}

- (SSCallbackEvent *) getDefinitionOf: (NSString *) type
              onCallback: (SSClientCallback) callback
{
    [self initCall:@"getDefinition"];
    url = [NSString stringWithFormat:URL_ENTITY_FORMAT, baseUrl, type, @"definition"];
   
    event.uri = url;
    event.cachedEvent = [cacheManager cachedEvent: url ofType: type];
    event.objectType = type;

    if ([self queueRequest:url callback:callback])
    {
        return event.cachedEvent;
    }
    callbackBlock = callback;
    [self connect:[self requestForGet]];
    return event.cachedEvent;
}

- (void) invalidateCachedObject: (NSString *) objectId
                  ofType: (NSString *) type
{
    
    url = [NSString stringWithFormat:URL_QUERY_FORMAT, baseUrl, type, objectId];
    event.objectType = type;
    event.uri = url;
    [cacheManager invalidateCache:url ofType:type];
}

- (void) invalidateCache: (SSQuery *) query
                  ofType: (NSString *) type
{
    url = [NSString stringWithFormat:URL_QUERY_FORMAT, baseUrl, type, [query toUrlQuery]];
    event.objectType = type;
    event.uri = url;
    [cacheManager invalidateCache:url ofType:type];
}

- (BOOL) queueRequest: (NSString *) requestUrl
             callback: (SSClientCallback) callback
{
    if (!requestQueue)
    {
        requestQueue = [NSMutableDictionary dictionary];
    }
    @synchronized(requestQueue)
    {
        NSMutableArray *callbacks = [requestQueue objectForKey:requestUrl];
        if (callbacks == nil)
        {
            callbacks = [NSMutableArray array];
            [requestQueue setObject:callbacks forKey:requestUrl];
            return NO; //first in the queue, we are going to make the call
        }
        else
        {
             //if one call is alread calling, then we will wait
            [callbacks addObject: callback];
            return YES;
        }
    }
}

- (SSCallbackEvent *) query: (SSQuery *) query
        ofType: (NSString *) type
    onCallback: (SSClientCallback) callback
{
    [self initCall:@"query"];
    url = [NSString stringWithFormat:URL_QUERY_FORMAT, baseUrl, type, [query toUrlQuery]];
    callbackBlock = callback;
    event.uri = url;
    event.cachedEvent = [cacheManager cachedEvent: url ofType: type];
    DebugLog(@"query on %@", url);
    //handle multiple request on the same url
    if ([self queueRequest:url callback:callback])
    {
        return event.cachedEvent;
    }
    
    event.objectType = type;
    [self connect:[self requestForGet]];
    return event.cachedEvent;
}

//Constructor
+ (SSClient *) instanceForApp:(id) application
                      withKey:(NSString *) applKey
{
    return (SSClient *) [[SSClient alloc] initForApp:application withKey:applKey];
}

- (id) initForApp:(id) application
          withKey:(NSString *) applKey
{
    self = [super init];
    if (self)
    {
        timeout = DEFAULT_HTTP_TIME_OUT;//default time
        appName = application;
        appKey = applKey;
        observers = [NSMutableArray array];
        cacheManager = [[SSClientCacheMgr alloc]init];
    }
    return self;
}

- (SSClient *) addObserver:(id<SSClientObserver>) observer
{
    [observers addObject:observer];
    return self;
}

- (SSClient *) removeObserver:(id<SSClientObserver>) observer
{
    [observers removeObject:observer];
    return self;
}

- (SSClient *) setSync:(BOOL) sync
{
    syncMode = sync;
    return self;
}

- (SSClient *) setTimeout:(int) time
{
    timeout = time;
    return self;
}

- (SSClient *) setBaseUrl:(NSString *) newUrl
{
    baseUrl = newUrl;
    return self;
}

- (SSClient *) setCachePolicy: (id) newPolicy
{
    cachePolicy = newPolicy;
    return self;
}

@end
 
