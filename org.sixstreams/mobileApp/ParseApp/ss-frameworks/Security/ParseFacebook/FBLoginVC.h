//
//  Copyright (c) 2013 Parse. All rights reserved.

#import <UIKit/UIKit.h>
#import "SSSecurityVC.h"

@interface FBLoginVC : SSSecurityVC

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)loginButtonTouchHandler:(id)sender;

@end
