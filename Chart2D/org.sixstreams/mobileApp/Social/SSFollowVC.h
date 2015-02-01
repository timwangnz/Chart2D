//
//  SSFollowVC.h
//  SixStreams
//
//  Created by Anping Wang on 4/18/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"

@interface SSFollowVC : SSTableViewVC

/**
 * User profile whose followers are shown
 */
@property (nonatomic) id item;
@property BOOL showFollowers;

@end
