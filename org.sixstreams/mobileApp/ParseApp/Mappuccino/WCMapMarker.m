//
//  WCMapMarker.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/18/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCMapMarker.h"
#import "SSGeoCodeUtil.h"

@implementation WCMapMarker
@synthesize coordinate,title,subtitle;
@synthesize roaster = _roaster;


+ (WCMapMarker *) getMyMarker
{
    WCMapMarker *ann = [[WCMapMarker alloc] init];
    ann.roaster = nil;
    ann.title = @"";
    ann.subtitle = @"";
    ann.coordinate = [[[SSGeoCodeUtil alloc]init] getCurrentCoordinate];

    return ann;
}

+ (WCMapMarker *) getMarker :(NSMutableDictionary *) roaster
{
 
    NSString *sLatitude = [roaster objectForKey:@"latitude"];
    float latitude = [sLatitude floatValue];
    NSString *sLongitude = [roaster objectForKey:@"longitude"];
    float longitude = [sLongitude floatValue];
    CLLocationCoordinate2D cord = {latitude, longitude};
    
    WCMapMarker *ann = [[WCMapMarker alloc] init];
    
    ann.roaster = roaster;
    ann.title = [roaster objectForKey:@"name"];
    ann.subtitle = [roaster objectForKey:@"beans"] ? [roaster objectForKey:@"beans"] : @"";
    ann.coordinate = cord;
    return ann;
}

@end
