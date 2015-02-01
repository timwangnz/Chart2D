//
//  SSMedistoryApp.m
//  Glue
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SSSplitsApp.h"
#import "SSSplitsModelVC.h"
#import "SSNearByVC.h"

@interface SSSplitsApp ()
{
    
}
@end;


@implementation SSSplitsApp

- (id) init
{
    self = [super init];
    if (self)
    {
        self.isPublic = YES;
        
        self.name = @"Splits";
        
    }
    return self;
}

- (UIViewController *) createRootVC
{
    if (CLLocationManager.locationServicesEnabled == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                                        message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
   
    
    SSNearByVC *nearbyVC = [[SSNearByVC alloc]init];
    nearbyVC.showDeviceLoc = YES;
    nearbyVC.searchAllowed = NO;
    nearbyVC.deltaLatitude = 0.2;
    nearbyVC.deltaLongitude = 0.2;
    nearbyVC.title = @"Track Me";
    return  [[UINavigationController alloc]initWithRootViewController:nearbyVC];
}


@end
