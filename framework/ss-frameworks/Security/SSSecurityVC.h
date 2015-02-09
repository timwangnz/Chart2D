//
// AppliaticsSigninVC.h
// Appliatics
//
//  Created by Anping Wang on 10/2/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonVC.h"

@protocol SSSigninDelegate <NSObject>
- (void) didLogin : (id) user;
- (void) didSignup : (id) user;
- (void) didLogoff;
@end

typedef void (^SSLoginCallBack)(id user);
typedef void (^SSCallBack)(id profile);

@interface SSSecurityVC : SSCommonVC

@property (nonatomic, strong) id<SSSigninDelegate> signinDelegate;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *invitationId;
@property BOOL cancellable;
@property (nonatomic, strong) SSLoginCallBack callbackBlock;

+ (SSSecurityVC *) instance;

+ (void) signoff;
+ (BOOL) isSignedIn;


+ (void) cancelAccount;

+ (void) deleteAccount:(id) profile;

+ (NSString *) username;

+ (void) checkLogin:(SSCommonVC *) callerVC
           withHint:(NSString *) hint
         onLoggedIn:(SSLoginCallBack) callback;

+ (id) profile;

+ (void) invalidateCachedProfile;
//for other login agent
- (void) didSignup;
//for other login agent
- (void) didSignin;
- (BOOL) autoSignin;
- (void) signoff;

@end
