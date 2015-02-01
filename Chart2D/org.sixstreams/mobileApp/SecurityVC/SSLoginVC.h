//
//  SSLoginVC.h
//  Mappuccino
//
//  Created by Anping Wang on 4/6/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSClientDataVC.h"

typedef void (^SSLoginCallBack)(id user);

@interface SSLoginVC : SSClientDataVC

@property (nonatomic, strong) NSString *hint;
@property BOOL cancellable;

+ (void) checkLogin:(UIViewController *) callerVC
           withHint:(NSString *) hint
         onLoggedIn:(SSLoginCallBack) callback;

+ (void) signoff :(UIViewController *) vc;
+ (void) removeAccount:(UIViewController *) vc;

+ (id) getProfile;
+ (id) getUser;

+ (void) updateProfile:(id) newProfile;
+ (NSString *) getUsername;
+ (NSString *) getPassword;
+ (NSString *) getAuthSource;

+ (BOOL) isSignedIn;
+ (BOOL) isItemEditable :(id) item;
@end
