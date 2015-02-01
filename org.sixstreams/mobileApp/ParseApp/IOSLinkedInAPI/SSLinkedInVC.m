//
//  SSLinkedInVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/30/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSLinkedInVC.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"

@interface SSLinkedInVC ()
{
    LIALinkedInHttpClient *client;
}

@end

@implementation SSLinkedInVC
#define LINKEDIN_CLIENT_ID @"qp1taibb1pu4"
#define LINKEDIN_CLIENT_SECRET @"RVc9Ab6vsprzeLSd"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *grantedAccess = @[@"r_fullprofile", @"r_network"];
    
    NSString *clientId = LINKEDIN_CLIENT_ID; //the client secret you get from the registered LinkedIn application
    NSString *clientSecret = LINKEDIN_CLIENT_SECRET; //the client secret you get from the registered LinkedIn application
    NSString *state = @"WREEQAF45sersdffef424"; //A long unique string value of your choice that is hard to guess. Used to prevent CSRF
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.mypacswim.com" clientId:clientId clientSecret:clientSecret state:state grantedAccess:grantedAccess];
    client = [LIALinkedInHttpClient clientForApplication:application];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(0, 0, 300, 44);
    loginButton.center = CGPointMake(CGRectGetMidX(self.view.frame), 50);
    [loginButton setTitle:@"Login to LinkedIn" forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
    [loginButton addTarget:self action:@selector(didPressLogin:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didPressLogin:(id)sender {
    [client getAuthorizationCode:^(NSString *code) {
        NSLog(@"got cosw %@", code);
        [client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSLog(@"got token %@", accessTokenData);
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            [client get:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken]
                success:^(NSDictionary *response) {
                    NSLog(@"data %@", response);
                }
                failure:^(NSError *error) {
                    NSLog(@"error %@", error);
                }];
        }
                       failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                          cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                         failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
    
}

@end
