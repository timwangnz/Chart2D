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
#import "SSSecurityVC.h"
#import "SSClientCacheMgr.h"
#import "SSReachability.h"
#import "ObjectTypeUtil.h"
#import "ConfigurationManager.h"
#import "SSConnection.h"

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
              setBaseUrl:@"org.sixstreams.social"]
             setTimeout:60] setCachePolicy:@"enabled"];
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

- (NSString *) description
{
    return [NSString stringWithFormat:@"url:%@\nheader:%@\nUsername:%@", url, header, username];
}

////////////////////////////////////////////////////////

- (void) initHeader
{

    [self initEvent];
}

- (void) initCall:(NSString *) ctx
{
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
    
    //TODO
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
    //TODO
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
    
    //TODO
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
   // if ([self queueRequest:url callback:callback])
   // {
     //   callbackBlock = nil;
       // return event.cachedEvent.data;
   // }
    
   //TODO

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
    
    url = [NSString stringWithFormat:URL_COLLECTION_FORMAT, baseUrl, type];
    event.uri = url;
    //TODO
    return NO;
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
    
    SSConnection *conn = [SSConnection connector];
    [conn createObject:object
                ofType:type
             onSuccess:^(NSDictionary *data) {
                 event.data = data;
                 callback(event);
             } onFailure:^(NSError *error) {
                 event.error = error;
                 callback(event);
             }
     ];
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
    SSConnection *conn = [SSConnection connector];
    [conn createObject:object
                ofType:type
             onSuccess:^(NSDictionary *data) {
                 event.data = data;
                 callback(event);
             } onFailure:^(NSError *error) {
                 event.error = error;
                 callback(event);
             }
     ];
    //TODO
}

- (void) deleteObject:(NSDictionary *) object
               ofType:(NSString *) type
           onCallback:(SSClientCallback) callback
{
    [self initCall:@"deleteObject"];
    callbackBlock = callback;
    url = [NSString stringWithFormat:URL_ENTITY_FORMAT, baseUrl, type, [object objectForKey:OBJECT_ID]];
    event.uri = url;

    event.objectType = type;
    SSConnection *conn = [SSConnection connector];
    [conn deteteObject:object
                ofType:type
             onSuccess:^(NSDictionary *data) {
                 event.data = data;
                 callback(event);
             } onFailure:^(NSError *error) {
                 event.error = error;
                 callback(event);
             }
     ];
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

    //if ([self queueRequest:url callback:callback])
  //  {
      //  return event.cachedEvent;
   // }
    
    //TODO
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
    SSConnection *conn = [SSConnection connector];

    [conn getObject:objectId
             ofType:type
          onSuccess:^(NSDictionary *data) {
              event.data = data;
              callback(event);
          } onFailure:^(NSError *error) {
              event.error = error;
              callback(event);
          }
     ];
    
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
    //if ([self queueRequest:url callback:callback])
    //{
      //  return event.cachedEvent;
    //}
    
    event.objectType = type;
    SSConnection *conn = [SSConnection connector];

    [conn getObjects:nil
              ofType:type
             orderBy:[query orderBy]
           ascending:YES
              offset:[query offset]
               limit:[query limit]
          onSuccess:^(NSDictionary *data) {
              event.data = [data objectForKey:PAYLOAD];
              event.callingStatus = SSEVENT_SUCCESS;
              callback(event);
          } onFailure:^(NSError *error) {
              event.error = error;
              event.callingStatus = SSEVENT_ERROR;
              callback(event);
          }
     ];
    return event.cachedEvent;
}

//Constructor
+ (SSClient *) instanceForApp: (id) application
                      withKey: (NSString *) applKey
{
    return (SSClient *) [[SSClient alloc] initForApp:application withKey:applKey];
}

- (id) initForApp: (id) application
          withKey: (NSString *) applKey
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
 
