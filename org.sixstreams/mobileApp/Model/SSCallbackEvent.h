//
//  SSCallbackEvent.h
//  Mappuccino
//
//  Created by Anping Wang on 4/9/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>
 
enum {
    SSEVENT_IN_PROGRESS,
    SSEVENT_SUCCESS,
    SSEVENT_ERROR
};

typedef NSInteger SSEventStatus;

@interface SSCallbackEvent : NSObject

@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) NSString *callerContext;
@property (nonatomic, retain) NSString *uri;
@property (nonatomic, retain) id data;
@property (nonatomic, retain) id client;
@property (nonatomic, retain) SSCallbackEvent *cachedEvent;

@property int contentLength;
@property int responseCode;

//properties used when it returned from cache
@property BOOL cached;
@property BOOL expired;

@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSString *objectType;

@property (nonatomic, retain) NSMutableDictionary *userInfo;
@property SSEventStatus callingStatus;
 
@end
