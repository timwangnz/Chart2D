//
//  SSInviteVC.h
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"

@interface SSInviteVC : SSTableViewVC

@property BOOL myInvites;

- (BOOL) isInvited:(NSString *) username;

@end
