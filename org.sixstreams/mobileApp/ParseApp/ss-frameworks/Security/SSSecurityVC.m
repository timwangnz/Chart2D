//
// AppliaticsSigninVC.m
// Appliatics
//
//  Created by Anping Wang on 10/2/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSSecurityVC.h"
#import "SSTableViewVC.h"
#import "SSKeyChainUtil.h"
#import "SSAppDelegate.h"

#import "SSProfileVC.h"
#import <Parse/Parse.h>
#import "SSConnection.h"
#import "SSAppSetupVC.h"
#import "SSStorageManager.h"
#import "SSLovTextField.h"
#import "FBLoginVC.h"
#import "SSApp.h"

#define AUTHO_SOURCE @"parse.com"
#define SIGN_IN @"Signin"
#define SIGN_UP @"Signup"

@interface SSSecurityVC ()
{
    IBOutlet UIButton *btnCancel;
    IBOutlet UILabel *lEmail;
    IBOutlet UIButton *bSignin;
    IBOutlet UIButton *bChangView;
    IBOutlet UILabel *lInviationMode;
    
    IBOutlet UILabel *lPassword;
    IBOutlet UIButton *bForgetPwd;
    IBOutlet UITextField *tfEmail;
    IBOutlet UITextField *tfPassword;
    IBOutlet SSLovTextField *tfTitle;
    IBOutlet UITextField *tfFirstName;
    IBOutlet UITextField *tfLastName;
    IBOutlet UILabel *lTitle;
    IBOutlet UIView *loginView;
    IBOutlet UIView *vSignup;
    SSAppSetupVC *appSetup;
}
- (IBAction)changeView:(UIButton*)sender;
- (IBAction)registerOrganization:(id)sender;
@end

@implementation SSSecurityVC

static id cachedProfile;

+ (SSAppDelegate *) appDelegate
{
    return (SSAppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (SSSecurityVC *)instance
{
    SSSecurityVC *inst = [[SSSecurityVC alloc]init];
    if([[SSApp instance].loginAgent isEqualToString:@"facebook"])
    {
        inst = [[FBLoginVC alloc]init];
    }
    inst.signinDelegate = [self appDelegate];
    inst.appName = [SSApp instance].name;
    return inst;
}

+ (BOOL) isSignedIn
{
    return [PFUser currentUser].isAuthenticated;
}

+ (NSString *) password
{
    return [SSKeyChainUtil password];
}

+ (NSString *) username
{
    return [SSKeyChainUtil username];
}

+ (void) cancelAccount
{
    [[SSConnection connector] deleteMyAccount];
    [SSKeyChainUtil clearCredentials];
    [[SSStorageManager storageManager] cleanup];
    [[self appDelegate]signoff];
}

+ (void) deleteAccount:(id) profile
{
    [[SSConnection connector] deleteAccount:profile];
    
}

+ (void) invalidateCachedProfile
{
    cachedProfile = nil;
}

+ (id) profile
{
    PFUser *user =[PFUser currentUser];
    
    if (!user.isAuthenticated)
    {
        return nil;
    }
    
    if (cachedProfile)
    {
        return cachedProfile;
    }
    
    SSConnection *conn =[SSConnection connector];
    NSArray *profiles =
    [conn getObjects:[NSPredicate predicateWithFormat:@"username=%@", user.username ]
              ofType:PROFILE_CLASS
             orderBy:nil
           ascending:YES
              offset:0
               limit:10
             timeout:10000
     ];
    
    NSMutableDictionary *profile = [profiles count] > 0 ?
    [NSMutableDictionary dictionaryWithDictionary:[profiles objectAtIndex:0]] : nil;
    cachedProfile = profile;
    return profile;
}


+ (void) signoff
{
    [[SSSecurityVC instance] signoff];
    [[self appDelegate] signoff];
}

- (void) signoff
{
    [PFUser logOut];
    [SSKeyChainUtil clearCredentials];
    cachedProfile = nil;
}

- (BOOL) autoSignin
{
    NSString *username = [SSSecurityVC username];
    if (username && ![username isEqualToString:@""])
    {
        NSString *password = [SSSecurityVC password];
        PFUser *user = [PFUser logInWithUsername:username password:password];
        if(user)
        {
            self.callbackBlock(user);
            return YES;
        }
        else
        {
            [SSKeyChainUtil clearCredentials];
            return NO;
        }
        
    }
    return NO;
}

+ (void) checkLogin:(SSCommonVC *) callerVC
           withHint:(NSString *) hint
         onLoggedIn:(SSLoginCallBack) callback
{
    [[SSSecurityVC instance] checkLogin:callerVC withHint:hint onLoggedIn:callback];
}

- (void) checkLogin:(SSCommonVC *) callerVC
           withHint:(NSString *) hint
         onLoggedIn:(SSLoginCallBack) callback
{
    if ([SSSecurityVC isSignedIn])
    {
        callback([PFUser currentUser]);
    }
    else
    {
        self.callbackBlock = callback;
        self.view.backgroundColor = callerVC.view.backgroundColor;
        if(![self autoSignin])
        {
            if (callerVC)
            {
                [callerVC showPopup:self sender:callerVC.view];
            }
            else{
                callback(nil);
            }
        }
    }
}

- (IBAction)cancel:(id)sender {
    if (self.callbackBlock)
    {
        self.callbackBlock(nil);
    }
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ([self isIPad])
    {
        nibNameOrNil = @"SSSecurity-ipad";
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.title = @"Signin";
    
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *mail = tfEmail.text;
    if (tfPassword.hidden && mail != nil && mail.length > 0)
    {
        [self doSignin:bSignin];
        tfEmail.text = nil;
        [self hideKeyboard];
    }
}
- (IBAction)forgotPassword:(id)sender
{
    if (tfPassword.hidden) {
        NSString *mail = tfEmail.text;
        if (mail != nil && mail.length > 0)
        {
            [PFUser requestPasswordResetForEmailInBackground:mail];
            [self showAlert:@"Please check your email and follow the instructions to change your password" withTitle:@"Email sent"];
        }
        else{
            [self showAlert:@"Email is required to reset password" withTitle:@"Error"];
        }
    }
    else
    {
        [self changeView:sender];
    }
}

- (IBAction)registerOrganization:(id)sender
{
    appSetup = [[SSAppSetupVC alloc]init];
    appSetup.view.alpha = 0;
    [self.view addSubview:appSetup.view];
    [self.view bringSubviewToFront:appSetup.view];

    [UIView animateWithDuration:2 animations:^{
        appSetup.view.alpha = 1;
    }];
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.hidden = NO;
    tfTitle.attrName = USER_TYPE;
    self.title = self.appName;
    tfTitle.listOfValues = [[SSApp instance] getLov:USER_TYPE ofType:CATEGORY];
    lTitle.text = self.title;
    [self changeViewMode:YES];
    if ([[SSApp instance] invitationOnly])
    {
        bChangView.hidden = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    if (self.invitationId)
    {
        if([tfEmail isEmpty])
        {
            [self handleInvitation];
        }
    }
    else
    {
        if (![SSSecurityVC isSignedIn]) {
        //    [self clearForm:self.view];
        }
    }
    [self hideKeyboard];
}

- (void) handleInvitation
{
    id invitation = [[SSConnection connector] objectForKey:self.invitationId ofType:INVITATION_CLASS];
    if (invitation)
    {
        NSString *accepted = [invitation objectForKey: STATUS];
        if (!accepted)
        {
            NSString *email = [invitation objectForKey:EMAIL];
            tfEmail.text = email;
            tfEmail.enabled = false;
            bChangView.hidden = NO;
            [self changeView:bChangView];
            return;
        }
    }
    [self showAlert:@"Failed to locate your invitation, please get it again" withTitle:@"Error"];
}

- (IBAction)doSignin:(id)sender
{
    if (bSignin.tag == -1)
    {
        [bSignin setTitle:@"Signin" forState:UIControlStateNormal];
        [bForgetPwd setTitle:@"Forgot Password" forState:UIControlStateNormal];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            [self changeViewMode:YES];
            bSignin.tag = 0;
            [UIView commitAnimations];
        });
        return;
    }
    else
    {
        if ([tfPassword isEmpty] ||  [tfEmail isEmpty])
        {
            [[[UIAlertView alloc]initWithTitle:ERROR
                                       message:@"All fields are required"
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil] show];
            return;
        }
        
        BOOL signin = vSignup.hidden;
        if (!signin)
        {
            if(![self signup])
            {
                [[[UIAlertView alloc]initWithTitle:@"Error"
                                           message:@"Failed to sign up"
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil] show];
                return;
            }
        }
        cachedProfile = nil;
        [PFUser logInWithUsernameInBackground:tfEmail.text password:tfPassword.text block:^(PFUser *user, NSError *error) {
            if(!error)
            {
                [SSKeyChainUtil saveUsername: tfEmail.text authSource:nil password:tfPassword.text];
                [self didSignin];
            }
            else{
                tfPassword.text = @"";
                [[[UIAlertView alloc]initWithTitle:ERROR
                                           message:@"Failed to login, please check your username and password"
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil] show];
            }
        }];
    }
}

- (void) didSignin
{
    if (self.callbackBlock)
    {
        self.callbackBlock([PFUser currentUser]);
    }
    else
    {
        [self.signinDelegate didLogin:[PFUser currentUser]];
    }
}

- (id) newProfile
{
    NSMutableDictionary *profile = [NSMutableDictionary dictionary];
    [profile setValue:tfFirstName.text forKeyPath:FIRST_NAME];
    [profile setValue:tfLastName.text forKeyPath:LAST_NAME];
    [profile setValue:tfTitle.value forKeyPath:USER_TYPE];
    if(self.invitationId)
    {
        [profile setObject:self.invitationId forKey:INVIVATION_ID];
    }
    return profile;
}

- (void) didSignup
{
    [SSProfileVC createNewProfile:[self newProfile] onSuccess:^(id data) {
        if (self.callbackBlock)
        {
            self.callbackBlock ([PFUser currentUser]);
        }
    } onFailure:^(NSError *error) {
        self.callbackBlock (nil);
    }];
}

- (BOOL) signup
{
    PFUser *user = [PFUser user];
    user.username = tfEmail.text;
    user.email = tfEmail.text;
    user.password = tfPassword.text;
    
    if([user signUp])
    {
        [self didSignup];
        return YES;
    }
    else
    {
        return NO;
    }
}

- (IBAction)changeView:(UIButton*)sender
{
    if ([sender isEqual:bForgetPwd])
    {
        bSignin.tag = -1;
        tfPassword.hidden = YES;
        lPassword.hidden = YES;
        [bForgetPwd setTitle:@"Submit" forState:UIControlStateNormal];
        
        float y = 90;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            
            bSignin.frame = CGRectMake(loginView.frame.size.width/2 - 75,y,
                                       80,
                                       bSignin.frame.size.height);
            
            
            bForgetPwd.frame = CGRectMake(loginView.frame.size.width/2 + 5,y,
                                          80,
                                          bForgetPwd.frame.size.height);
            
            [bSignin setTitle:@"Cancel" forState:UIControlStateNormal];
            
            loginView.frame = CGRectMake(loginView.frame.origin.x,loginView.frame.origin.y,
                                         loginView.frame.size.width,
                                         140);
            [UIView commitAnimations];
        });
    }
    else
    {
        bSignin.tag = 0;
        [UIView animateWithDuration:0.2 animations:^{
            [self changeViewMode:!vSignup.hidden];
        }];
    }
}

- (void)changeViewMode:(BOOL) signin
{
    bSignin.hidden = YES;
    vSignup.hidden = signin;
    //tfEmail.text = nil;
    tfTitle.text = nil;
    tfPassword.text = nil;
    tfPassword.hidden = NO;
    lPassword.hidden = NO;
    tfFirstName.text = nil;
    tfFirstName.text = nil;
    
    if (!signin)
    {
        CGRect frame = loginView.frame;
        frame.size.height = 290;
        frame.origin.y = 80;
        loginView.frame = frame;
        frame = bSignin.frame;
        frame.origin.y = 235;
        bSignin.frame = frame;
        frame = bForgetPwd.frame;
        frame.origin.y = 235;
        bSignin.center = CGPointMake(loginView.frame.size.width/2, 255);
        bForgetPwd.hidden = YES;
    }
    else
    {
        CGRect frame = loginView.frame;
        frame.size.height = 200;
        frame.origin.y = 100;
        loginView.frame = frame;
        frame = bSignin.frame;
        frame.origin.y = 125;
        bSignin.frame = frame;
        bForgetPwd.hidden = NO;
        bSignin.frame = CGRectMake(bSignin.frame.origin.x,bSignin.frame.origin.y,
                                   116,
                                   bSignin.frame.size.height);
        
        
        bForgetPwd.frame = CGRectMake(bForgetPwd.frame.origin.x,bForgetPwd.frame.origin.y,116,
                                      bForgetPwd.frame.size.height);
        
         bSignin.center = CGPointMake(loginView.frame.size.width/2, 145);
         bForgetPwd.center = CGPointMake(loginView.frame.size.width/2, 180);
        [bForgetPwd setTitle:@"Forgot Password" forState:UIControlStateNormal];
    }
    
    btnCancel.hidden = !self.cancellable;
    
    self.title = [NSString stringWithFormat:@"%@ %@", signin ? SIGN_IN : SIGN_UP, self.appName];
    [bSignin setTitle: signin ? SIGN_IN : SIGN_UP forState:UIControlStateNormal];
    [bChangView setTitle: signin ? SIGN_UP : SIGN_IN forState:UIControlStateNormal];
    bSignin.hidden = NO;
    [self hideKeyboard];
}


@end
