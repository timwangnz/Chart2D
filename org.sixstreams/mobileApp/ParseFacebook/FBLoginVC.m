//
//  Copyright (c) 2013 Parse. All rights reserved.

#import "FBLoginVC.h"
#import "UserDetailsViewController.h"
#import <Parse/Parse.h>
#import "SSProfileVC.h"
#import "SSApp.h"

@interface FBLoginVC ()
{
    IBOutlet UIImageView *logoView;
}

@end;

@implementation FBLoginVC


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        if (self.signinDelegate)
        {
            [self.signinDelegate didLogin:[PFUser currentUser]];
        }
        else
        {
            [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:NO];
        }
    }
    logoView.image = [UIImage imageNamed:[[SSApp instance] getAppIconName]];
}

- (BOOL) autoSignin
{
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.callbackBlock([PFUser currentUser]);
        return YES;
    }
    return NO;
}

#pragma mark - Login mehtods

/* Login to facebook method */
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me"];//, @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using facebook
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                [self showAlert:@"Uh oh. The user cancelled the Facebook login." withTitle:@"Log In Error"];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not login with Facebook"
                                                                message:@"Facebook login failed. Please check your Facebook settings on your phone."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            NSLog(@"%@", error.userInfo);
            }
        } else if (user.isNew) {
            
            [self updateProfile];
        } else {
            
            [self updateProfile];
        }
    }];
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void) updateProfile
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
             NSMutableDictionary *userProfile = (NSMutableDictionary*) [SSSecurityVC profile];
            if (!userProfile)
            {
                userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            }
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[NAME]) {
                userProfile[NAME] = userData[NAME];
                
                userProfile[FIRST_NAME] = [userData[NAME] componentsSeparatedByString:@" "][0];
                userProfile[LAST_NAME] = [userData[NAME] componentsSeparatedByString:@" "][1];
                userProfile[USER_TYPE] = @"facebook";
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
        
            [SSProfileVC createNewProfile:userProfile onSuccess:^(id data) {
                DebugLog(@"Facebook profile updated");
                [self didSignin];
            } onFailure:^(NSError *error) {
                DebugLog(@"Facebook profile failed to update");
            }];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) {
            // Since the request failed, we can check if it was due to an invalid session
            DebugLog(@"The facebook session was invalidated");
            //[self logoutButtonTouchHandler:nil];
        } else {
            DebugLog(@"Some other error: %@", error);
        }
    }];
    
}

@end
