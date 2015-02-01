//
//  HWDMasterViewController.h
//  HandWritingDemo
//
//  Created by Anping Wang on 12/22/12.
//  Copyright (c) 2012 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSDrawableVC;

@interface HWDMasterViewController : UITableViewController

@property (strong, nonatomic) SSDrawableVC *detailViewController;

@end
