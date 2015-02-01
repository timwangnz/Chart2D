//
//  SSLoginVC.m
//  Mappuccino
//
//  Created by Anping Wang on 4/6/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//
#import "SSLoginVC.h"
#import "SSClientCacheMgr.h"
#import "SSStorageManager.h"
#import "ConfigurationManager.h"
#import "SSKeyChainUtil.h"
#import "SSJSONUtil.h"

@interface SSLoginVC ()
{
    SSLoginCallBack callbackBlock;
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    
    IBOutlet UITextField *signUpUsername;
    IBOutlet UITextField *signUppassword;
    IBOutlet UITextField *signUpEmail;
    
    IBOutlet UITextField *title;
    
    IBOutlet UILabel *loginMsg;
    IBOutlet UILabel *signupMsg;
    
    
    NSString *authSource;
    int mode;
    IBOutlet UIView *signupView;
    IBOutlet UIView *signinView;
    IBOutlet UIView *btnsView;
}

@property (strong, atomic) UIColor *background;

- (IBAction)doLogin:(id)sender;
- (IBAction)doSignup:(id)sender;
- (IBAction)showSignup:(id)sender;
- (IBAction)showSignin:(id)sender;
- (IBAction)performFBLogin:(id)sender;
- (IBAction)performFBLogout;
- (IBAction) cancelAction;

@end

@implementation SSLoginVC

#define PROFILE_STORAGE_KEY @"com.sixstream.user.Profile"

static NSDictionary* profile;
static id user;

+ (BOOL) isItemEditable:(id) item
{
    NSString *createdBy = [item objectForKey:@"createdBy"];

    return [createdBy isEqualToString: [profile objectForKey:@"id"]] || YES;
}

+ (void) signoff:(UIViewController *) vc
{
    [[SSStorageManager getStorageManager] clearJson:PROFILE_STORAGE_KEY];
    [SSClientCacheMgr clearCache];
    [SSKeyChainUtil clearCredentials];
    profile = nil;
    user = nil;
    [FBSession.activeSession closeAndClearTokenInformation];
   
    
}

+ (void) removeAccount:(UIViewController *) vc
{
    [[SSClient getClient] removeAccount: [self getUsername]
                               password:[self getPassword]
                            oAuthSource:[self getAuthSource]
                             onCallback:^(SSCallbackEvent *event) {
                                 if (event.callingStatus == SSEVENT_SUCCESS)
                                 {
                                     [self signoff:vc];
                                 }
                             }
      ];
}

+ (BOOL) isLoggedIn
{
    NSString *username = [self getUsername];
    return user && username &&[username length] > 0 && ![username isEqualToString : ANONYMOUS];
}

+ (BOOL) isSignedIn
{
    return user != nil;
}

+ (NSString *) getUsername
{
    return [SSKeyChainUtil username];
}

+ (NSString *) getAuthSource
{
    return [SSKeyChainUtil authSource];
}

+ (NSString *) getPassword
{
    return [SSKeyChainUtil password];
}

+ (void) updateProfile:(id) newProfile
{
    [[SSClient getClient] updateObject:newProfile
                                ofType:PROFILE_TYPE
                            onCallback:^(SSCallbackEvent *event) {
                                if (event.error)
                                {
                                    
                                }
                                else if(event.callingStatus == SSEVENT_SUCCESS)
                                {
                                    profile = newProfile;
                                    [SSLoginVC saveProfile:profile];
                                }
                            }
     ];
}

+ (id) getUser
{
    return user;
}

+ (id) getProfile
{
    if (profile == nil)
    {
        //get from cache
        profile = [[SSStorageManager getStorageManager] read:PROFILE_STORAGE_KEY];
        if (profile != nil)
        {
            //
            //if not nil, we will try to update from internet
            //
            [[SSClient getClient] getObject:[profile objectForKey:@"id"]
                                     ofType:PROFILE_TYPE
                                 onCallback:^(SSCallbackEvent *event) {
                                     if (event.error)
                                     {
                                         //
                                         //if failed, do nothing, just use the one from the cache
                                         //
                                     }
                                     else if(event.callingStatus == SSEVENT_SUCCESS)
                                     {
                                         //update profile to the latest from the internet
                                         profile = event.data;
                                         //update cache now
                                         [SSLoginVC saveProfile:profile];
                                     }
                                 }
             ];
        }
    }
    return profile;
}

+ (void) checkLogin:(UIViewController *) callerVC
           withHint:(NSString *) hint
         onLoggedIn:(SSLoginCallBack) callback
{
    NSString *username = [self getUsername];
    if ([self isLoggedIn])
    {
        callback(username);
    }
    else
    {
        if (username && ![username isEqualToString:@""])
        {   //if we already have username, but we have not verified with the server, do so here
            [[SSClient getClient] login:[self getUsername]
                               password:[self getPassword]
                            oAuthSource:[self getAuthSource]
                             onCallback:^(SSCallbackEvent *event) {
                                 if (event.error)
                                 {
                                     //this means our username might have been expired. We need
                                     //check the error to be exactly access denied.
                                     //for any other errors, display to the user and ask them
                                     //try later
                                     SSLoginVC *logginVC = [[SSLoginVC alloc]init];
                                     logginVC.title = @"Signin";
                                     logginVC.hint = hint;
                                     [logginVC setBlock:callback];
                                     [callerVC presentViewController: [[UINavigationController alloc]  initWithRootViewController:logginVC]
                                                            animated: YES
                                                          completion: nil];
                                 }
                                 else if(event.callingStatus == SSEVENT_SUCCESS)
                                 {
                                     user = event.data;
                                     profile = [user objectForKey:@"profile"];
                                     if (!profile)
                                     {
                                         SSLoginVC *logginVC = [[SSLoginVC alloc]init];
                                         logginVC.title = @"Signin";
                                         logginVC.hint = hint;
                                         [logginVC setBlock:callback];
                                         [callerVC presentViewController: [[UINavigationController alloc]  initWithRootViewController:logginVC]
                                                                animated: YES
                                                              completion: nil];

                                     }
                                     else
                                     {
                                         [SSLoginVC saveProfile:profile];
                                         callback(profile);
                                     }
                                 }
                             }
             ];
        }
        else
        {
            //if we dont have username, as user to sign with
            SSLoginVC *logginVC = [[SSLoginVC alloc]init];
            logginVC.title = @"Signin";
            logginVC.hint = hint;
            [logginVC setBlock:callback];
           
            [callerVC presentViewController: [[UINavigationController alloc]  initWithRootViewController:logginVC]
                                   animated:YES
                                 completion:nil];
        }
    }
}

+ (void) saveProfile :(id) profile
{
    [[SSStorageManager getStorageManager] save: profile uri:PROFILE_STORAGE_KEY];
}

- (IBAction) cancelAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    loginMsg.text = self.hint ? self.hint : @"Please Sign In";
    signupMsg.text = loginMsg.text;
   // self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.hidden = YES;
    currentView = btnsView;
    signinView.backgroundColor= self.view.backgroundColor;
    signupView.backgroundColor = self.view.backgroundColor;
    if (mode == 1)
    {
        self.view = signinView;
    }
    if (mode == 2){
        self.view = signupView;
    }
    
    

}

- (void) cancel:(id) sender
{
    if ([currentView isEqual:btnsView])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self switchView:btnsView withOptions:UIViewAnimationOptionTransitionCrossDissolve];
    }
}

- (IBAction)showSignup:(id)sender
{
    SSLoginVC *loginVC = [[SSLoginVC alloc]init];
    [loginVC setSignupView];
    
    [self.navigationController pushViewController:loginVC animated:YES];
    
    authSource = SIX_STREAMS_COM;
}

- (void) setSigninView
{
    mode = 1;
}

- (void) setSignupView
{
    mode = 2;
}

- (IBAction)showSignin:(id)sender
{
    SSLoginVC *loginVC = [[SSLoginVC alloc]init];
    
    [loginVC setSigninView];
    [loginVC setBlock:callbackBlock];
    [self.navigationController pushViewController:loginVC animated:YES];
    
    authSource = SIX_STREAMS_COM;
}


- (void) onSignup : (id) object
{
    [SSKeyChainUtil saveUsername:signUpUsername.text authSource:authSource password:signUppassword.text];
    user = object;
    profile = [user objectForKey:@"profile"];
    [SSLoginVC saveProfile:profile];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (callbackBlock)
    {
        callbackBlock(object);
    }
}

- (void) onLogin : (id) object
{
    [SSKeyChainUtil saveUsername:username.text authSource:authSource password:password.text];
    user = object;
    profile = [user objectForKey:@"profile"];
    [SSLoginVC saveProfile:profile];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if (callbackBlock)
    {
        callbackBlock(object);
    }
}

-(IBAction) doLogin:(id)sender
{
    if ([NSString isEmpty: password.text] || [NSString isEmpty: username.text])
    {
        [self showAlert:@"Error" message:@"All fields are required!"];
    }
    else
    {
        [[SSClient getClient] login: username.text
                           password: password.text
                        oAuthSource: authSource
                         onCallback:^(SSCallbackEvent *event) {
                             if (event.error)
                             {
                                 [self handleError:event];
                             }
                             else if(event.callingStatus == SSEVENT_SUCCESS)
                             {
                                 [self onLogin : event.data ];
                             }
                         }
         ];
    }
}

-(IBAction) doSignup:(id)sender
{
    if ([NSString isEmpty: signUppassword.text] || [NSString isEmpty: signUpUsername.text]|| [NSString isEmpty: signUpEmail.text])
    {
        [self showAlert:@"Error" message:@"All fields are required!"];
    }
    else
    {
        [[SSClient getClient] signup: signUpUsername.text
                            password: signUppassword.text
                               email: sender == nil ? nil : signUpUsername.text
                         oAuthSource: authSource
                             profile: [NSDictionary dictionaryWithObjectsAndKeys: signUpEmail.text, @"email", nil]
                          onCallback: ^(SSCallbackEvent *event) {
                              if (event.error)
                              {
                                  [self handleError:event];
                              }
                              else if(event.callingStatus == SSEVENT_SUCCESS)
                              {
                                  [self onSignup : event.data ];
                              }
                          }
         ];
    }
    
}

- (void) setBlock:(id) block
{
    callbackBlock = block;
}

#pragma Facebook oAuth

- (IBAction)performFBLogin:(id)sender
{
    
}

@end
