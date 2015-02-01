//
//  SSAppDelegate.h
//  Medistory
//
//  Created by Anping Wang on 9/23/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSSecurityVC.h"

@interface SSAppDelegate : UIResponder <UIApplicationDelegate, SSSigninDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) signoff;

@end
