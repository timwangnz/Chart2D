//
//  SSMembershipVC.h
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"
#import "SSConnection.h"

@interface SSMembershipVC : SSTableViewVC

@property (nonatomic, retain) NSString *group;



+ (void) groupsFor:(id) userId onSuccess: (SuccessCallback) callback;


+ (void) getMyGroupsOnSuccess: (SuccessCallback) callback;

+ (void) user:(id)profileId
isMemberOfGroup:(id) groupId
    onSuccess: (SuccessCallback) callback;

+ (void) user:(id)profileId
        leave:(id)groupId
    onSuccess: (SuccessCallback) callback;

+ (void) user: (id)user
         join: (id)group
    onSuccess: (SuccessCallback) callback;

@end
