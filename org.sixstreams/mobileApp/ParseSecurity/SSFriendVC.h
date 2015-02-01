//
//  SSFriendVC.h
//  Medistory
//
//  Created by Anping Wang on 11/7/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"
#import "SSConnection.h"

@interface SSFriendVC : SSTableViewVC

@property BOOL findAllowed;


+ (void) makeFriendWith: (id) friendProfile
              onSuccess:(SuccessCallback) callback
              onFailure: (ErrorCallback) errorCallback;

+ (void) checkIfIsMyFriend:(NSString *)userId
         onComplete: (SuccessCallback) callback;

@end
