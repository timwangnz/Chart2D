//
//  SSAppDelegate.m
//  Medistory
//
//  Created by Anping Wang on 9/23/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSAppDelegate.h"
#import "FBLoginVC.h"

#import "SSProfileEditorVC.h"
#import "SSApp.h"
#import <Parse/Parse.h>
#import "SSConnection.h"


@interface SSAppDelegate()
{
    UIViewController *main;
    SSSecurityVC *signinVC;
    SSApp *app;
    BOOL useFacebook;
}
@end

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //[application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    app = [SSApp instance];
    
    [Parse setApplicationId: app.appId clientKey: app.appKey];
    
    if ([app.loginAgent isEqualToString:@"facebook"])
    {
        useFacebook = YES;
        [PFFacebookUtils initializeFacebook];
    }
    else
    {
        if ([PFUser currentUser].isAuthenticated)
        {
            [PFUser logOut];
        }
    }
    UIView *bg = [app backgroundView];
    if (bg)
    {
        bg.frame = self.window.frame;
        [self.window addSubview:bg];
        [self.window sendSubviewToBack:bg];
    }
    
    self.window.rootViewController = [app createWelcomeVC];
    if(!app.isPublic)
    {
        [SSSecurityVC checkLogin:nil withHint:@"Signin" onLoggedIn:^(id user) {
            if (!user)
            {
                signinVC = [SSSecurityVC instance];
                signinVC.signinDelegate = self;
                signinVC.appName =  app.name;
                self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: signinVC];
            }
            else
            {
                [self showAppUI];
            }
        }];
    }
    else
    {
        [self showAppUI];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) loginWithFacebook
{
    [PFFacebookUtils initializeFacebook];
    // Override point for customization after application launch.
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FBLoginVC alloc] init]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSDictionary *dict = [self parseQueryString:[url query]];
    signinVC = [SSSecurityVC instance];
    signinVC.signinDelegate = self;
    signinVC.invitationId = [dict objectForKey:@"id"];
    signinVC.appName =  app.name;
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: signinVC];
    return YES;
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

/*
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}
 */

- (void) signoff
{
    if (app.isPublic)
    {
        [self showAppUI];
    }
    else
    {
        if(useFacebook)
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            [FBSession.activeSession close];
            [FBSession setActiveSession:nil];
        }
        signinVC = [SSSecurityVC instance];
        signinVC.signinDelegate = self;
        signinVC.appName =  app.name;
        [signinVC clearForm:signinVC.view];
        signinVC.view.alpha = 0;
        self.window.rootViewController = signinVC;
        [UIView animateWithDuration:0.5 animations:^{
            signinVC.view.alpha = 1;
        }];
    }
}

- (void) didSignup:(id) user
{
    [self didLogin:user];
}

- (void) didLogin:(id) user
{
    [self showAppUI];
}

- (void) didLogoff
{
    self.window.rootViewController = signinVC;
}

- (void) showAppUI
{
    main = [[SSApp instance] createRootVC];
    [[SSApp instance]customizeAppearance];
    self.window.rootViewController = main;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    if (useFacebook) {
        return [FBAppCall handleOpenURL:url
                      sourceApplication:sourceApplication
                            withSession:[PFFacebookUtils session]];
    }
    else if (url != nil && [url isFileURL]) {
        [[SSApp instance] readFile: annotation url:url];
    }
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. 
     If the application was previously in the background, optionally refresh the user interface.
     */
    if(useFacebook)
    {
        [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    if (useFacebook)
    {
        [[PFFacebookUtils session] close];
    }
}
@end
