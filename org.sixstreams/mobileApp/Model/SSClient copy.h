//
//  SSClient.h
//
//  Created by Anping Wang on 3/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSCallbackEvent.h"
#import "SSJSONUtil.h"
#import "SSQuery.h"

@class SSClient;

@protocol SSClientObserver <NSObject>
@required
    - (void) ssclient: (SSClient *) ssClient event:(SSCallbackEvent *)event;
@end

typedef void (^SSClientCallback)(SSCallbackEvent *event);

@interface SSClient: NSObject

+ (SSClient *) getClient;

//remote operation
- (void) removeAccount: (NSString *) user
              password: (NSString *) pwd
           oAuthSource: (NSString *)oAuthSource
            onCallback: (SSClientCallback) callback;

- (void) login: (NSString *) username
      password: (NSString *) password
   oAuthSource: (NSString *) oAuthSource
    onCallback: (SSClientCallback) callback;

- (void) signup: (NSString *) userid
       password: (NSString *) pwd
          email: (NSString *) email
    oAuthSource: (NSString *) oAuthSource
        profile: (id) profile
     onCallback: (SSClientCallback) callback;

//JSON Object API
- (void) createObject: (id) object
               ofType: (NSString *) type
           onCallback: (SSClientCallback) callback;

- (void) updateObject: (id) object
               ofType: (NSString *)type
           onCallback: (SSClientCallback) callback;

- (void) deleteObject: (id) object
               ofType: (NSString *) type
           onCallback: (SSClientCallback) callback;

- (SSCallbackEvent *) getObject:(NSString *) objectId
            ofType:(NSString *) type
        onCallback:(SSClientCallback) callback;

//this api can be used to retrieve any public json object 
- (SSCallbackEvent *) getJsonObjectAt:(NSString *) urlStr
                           onCallback:(SSClientCallback) callback;

- (SSCallbackEvent *) getDefinitionOf : (NSString *) type
              onCallback : (SSClientCallback) callback;

//a cached event will be returned at this point if exists
//update will come when remote objects are retrieved
- (SSCallbackEvent *) query: (SSQuery *) query
                     ofType: (NSString *) type
                 onCallback: (SSClientCallback) callback;

/**
 ** Invalidate cache for this query
 */
- (void) invalidateCache: (SSQuery *) query
                  ofType: (NSString *) type;

- (void) invalidateCachedObject: (NSString *) objectId
                         ofType: (NSString *) type;

//BLOB Stream API
- (BOOL) upload: (NSString *) path
           data: (NSData *) data2Upload
       iconData: (NSData *) iconData
   withMetaData: (NSDictionary *) metadata
     onCallback: (SSClientCallback) callback;

- (NSData *) download: (NSString *) path
       onCallback: (SSClientCallback) callback;

//building operation
+ (SSClient *) instanceForApp: (id) application
                      withKey: (NSString *) applKey;

- (SSClient *) setTimeout: (int) time;
- (SSClient *) setBaseUrl: (NSString *) newUrl;

- (SSClient *) setSync:(BOOL) syncMode;
- (SSClient *) addObserver: (id<SSClientObserver>) observer;
- (SSClient *) removeObserver: (id<SSClientObserver>) observer;
- (SSClient *) setCachePolicy: (id) cachePolicy;

@end


