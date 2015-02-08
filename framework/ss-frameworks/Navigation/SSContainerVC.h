//
//  SSContainerVC.h
//  SixStreams
//
//  Created by Anping Wang on 6/9/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSNavMenuVC.h"
#import "SSMainVC.h"

@interface SSContainerVC : SSCommonVC

@property (nonatomic, retain) SSNavMenuVC *menuVC;
@property (nonatomic, retain) SSMainVC *mainVC;

-(IBAction)openMenu:(id)sender;

@end
