//
//  PixelServer.h
//  Bluekai
//
//  Created by Anping Wang on 1/17/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PixelServer : NSObject

typedef void (^SuccessBlock)(NSData *data);
typedef void (^ErrorBlock)(id data);
typedef void (^ProgressBlock)(id data);

+ (NSString *) getBluekaiUUID;
+ (void) optOut;
+ (void)clearCookies;

+ (PixelServer *) forSite:(NSString *) siteId;
+ (void) tagUser:(NSDictionary *) data;

+ (void) tagUser: (NSDictionary *) data
       onSuccess: (SuccessBlock) callback
      onProgress: (ProgressBlock) progress
       onFailure: (ErrorBlock) errorCallback;


- (PixelServer *) enableIdfa:(BOOL) enableIdfa;
- (void) tagUser:(NSDictionary *) data;
- (void) tagUser:(NSDictionary *) data
       onSuccess: (SuccessBlock) callback
      onProgress: (ProgressBlock) progress
       onFailure: (ErrorBlock) errorCallback;

@end
