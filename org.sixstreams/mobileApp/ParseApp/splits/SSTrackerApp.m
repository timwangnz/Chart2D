//
//  SSMedistoryApp.m
//  Glue
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SSTrackerApp.h"
#import "SSDeviceTrackerVC.h"
#import "SSNearByVC.h"

@interface SSTrackerApp ()<SSNearByDelegate>
{
    SSNearByVC *nearbyVC;
    CLLocation *lastLocation;
    
}
@end;


@implementation SSTrackerApp

- (id) init
{
    self = [super init];
    if (self)
    {
        self.isPublic = YES;
        self.name = @"Tracker";
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
    
    SSDeviceTrackerVC *tracker = [[SSDeviceTrackerVC alloc]init];
    tracker.title = @"Take a picture";
    
    nearbyVC = [[SSNearByVC alloc]init];
    nearbyVC.showDeviceLoc = YES;
    nearbyVC.searchAllowed = NO;
    nearbyVC.trackDevice = YES;
    nearbyVC.deltaLatitude = 0.2;
    nearbyVC.deltaLongitude = 0.2;
    nearbyVC.delegate = self;
    
    nearbyVC.title = @"Track Me";
    return  tracker;//[[UINavigationController alloc]initWithRootViewController:tracker];
}

- (void) mapView:(id)view didDeviceMove:(CLLocation *)userLocation
{
    if(!lastLocation)
    {
        lastLocation = userLocation;
        return;
    }
    
    CLLocationDistance distance = [lastLocation distanceFromLocation:userLocation];
    NSTimeInterval distanceBetweenDates = [userLocation.timestamp timeIntervalSinceDate:lastLocation.timestamp ];
    if (distanceBetweenDates < 1)
    {
        return;
    }
    double velocity = distance / distanceBetweenDates;
    
    if (distance > 10 && distanceBetweenDates > 30)//once a minute and distance > 10 meter
    {
        lastLocation = userLocation;
        NSMutableDictionary *myLocation = [NSMutableDictionary dictionary];
        myLocation[LATITUDE]=[NSNumber numberWithDouble:userLocation.coordinate.latitude];
        myLocation[LONGITUDE]=[NSNumber numberWithDouble:userLocation.coordinate.longitude];
        myLocation[VELOCITY] = [NSNumber numberWithDouble:velocity];
        myLocation[DISTANCE] = [NSNumber numberWithDouble:distance];
        myLocation[DATE] = lastLocation.timestamp;
        myLocation[DEVICE_ID] = [self deviceId];
        
        [[SSConnection connector] createObject:myLocation ofType:@"sixstreams_tracker" onSuccess:^(id data) {
            //
        } onFailure:^(NSError *error) {
            
        }];
    }
}
@end
