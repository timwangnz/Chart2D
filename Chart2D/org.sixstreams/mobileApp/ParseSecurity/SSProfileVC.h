//
//  SSMeetUpVC.h
//  Medistory
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTableViewVC.h"
#import "SSConnection.h"

@interface SSProfileVC : SSTableViewVC

+ (void) createNewProfile: (id) data
                onSuccess: (SuccessCallback) callback
                onFailure: (ErrorCallback) errorCallback;

//+ (void) getProfileOnSuccess: (SuccessCallback) callback onFailure: (ErrorCallback) errorCallback;

+ (id) profile;
+ (id) currentLocation;

+ (void) getProfile:(NSString *)userId onComplete:(SuccessCallback) callback;

+ (NSString *) profileId;
+ (BOOL) isAdmin;
+ (NSString *) name;

+ (NSString *) domainName;


@end
