//
//  SSShuttleVC.h
//  Applatics
//
//  Created by Anping Wang on 10/13/13.
//  Copyright (c) 2013 Sixstreams. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SSShuttleVCDelegate <NSObject>
@optional
- (void) shuttleVC:(id) shuttle itemAdded : (id) entity;
- (void) shuttleVC:(id) shuttle itemRemoved : (id) entity;
@end


@interface SSShuttleVC : UIViewController

@property (nonatomic, strong) NSMutableArray *from;
@property (nonatomic, strong) NSMutableArray *to;
@property (nonatomic, strong) id<SSShuttleVCDelegate> delegate;

- (void) reloadData;
@end
