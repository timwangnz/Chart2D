//
//  ViewController.m
//  BluekaiDemo
//
//  Created by Anping Wang on 1/17/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BluekaiIDVC.h"

#import <AdSupport/AdSupport.h>
#import <Bluekai/Bluekai.h>

@interface BluekaiIDVC ()

- (IBAction)clearCookies:(id)sender;

@end

@implementation BluekaiIDVC

- (IBAction)clearCookies:(id)sender
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)tagUser:(id)sender
{
    [siteId resignFirstResponder];
    NSString *bkuuid = nil;
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSLog(@"Cookie in the jar %@ %@", cookie.name, cookie.value);
        if ([cookie.name isEqual:@"bku"])
        {
            bkuuid = cookie.value;
        }
    }
    
    NSInteger selected = categories.selectedSegmentIndex;
    NSString *cat = selected == 0 ? @"Auto" : selected == 1 ? @"Travel" : selected == 2 ? @"Computer" : @"Food";
    
    [[[PixelServer forSite:siteId.text] enableIdfa:enableAdfa.enabled]
        tagUser:@{@"in-market":cat}
        onSuccess:^(NSData *data) {
            NSString *bkuuid = nil;
            for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
            {
                NSLog(@"Cookie received %@ %@", cookie.name, cookie.value);
                if ([cookie.name isEqual:@"bku"])
                {
                    bkuuid = cookie.value;
                }
            }
            [[[UIAlertView alloc]initWithTitle:@"Success" message: [NSString stringWithFormat:@"BKUUID - %@", bkuuid] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        } onProgress:^(id data) {
            //
        } onFailure:^(id data) {
            //
        }
     ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    enableAdfa.enabled = YES;
    idfaLabel.text =
    [NSString stringWithFormat:@"IDFA:%@", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    
}

@end
