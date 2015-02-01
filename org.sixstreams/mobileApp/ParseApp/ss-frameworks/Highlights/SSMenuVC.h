//
//  SSMenuVC.h
//  SixStreams
//
//  Created by Anping Wang on 7/19/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"

@class SSMenuVC;

@protocol SSMenuVCDelegate <NSObject>
@required
- (void) menuVC:(SSMenuVC *) menuVC didSelect : (id) entity;
- (void) menuVC:(SSMenuVC *) menuVC open : (float) ratio;
@end


@interface SSMenuVC : SSTableViewVC

@property NSMutableArray *menuItems;
@property id<SSMenuVCDelegate> delegate;

@end
