//
//  SSMapMarker
//  
//
//  Created by Anping Wang on 9/18/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSMapMarker.h"
#import "SSGeoCodeUtil.h"
#import "DebugLogger.h"
#import "SSAddress.h"
#import "SSCommonVC.h"

@interface SSMapMarker()
{
    UIImageView * avarta;
}
@end

@implementation SSMapMarker

@synthesize coordinate;

+ (SSMapMarker *) getMyMarker
{
    SSMapMarker *ann = [[SSMapMarker alloc] init];
    ann.entity = nil;
    ann.title = @"";
    ann.subtitle = @"";
    
    ann.coordinate = [[[SSGeoCodeUtil alloc]init] getCurrentCoordinate];

    return ann;
}

+ (CLLocationCoordinate2D) updateLocation :(NSMutableDictionary *) location
{
    BOOL markable = [location objectForKey:STREET_ADDRESS] && [location objectForKey:CITY] && [location objectForKey:STATE];
    CLLocationCoordinate2D cord = {0, 0};
    if (!markable)
    {
        return cord;
    }
    
    NSString * theAddress = [NSString stringWithFormat:@"%@, %@, %@",
                             [location objectForKey:STREET_ADDRESS],
                             [location objectForKey:CITY],
                             [location objectForKey:STATE] ];
    
    
    cord = [[[SSGeoCodeUtil alloc]init] getCoordinates:[theAddress stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    if (cord.latitude == 0.0f)
    {
        DebugLog(@"Failed to decode %@", theAddress);
    }
    else
    {
        [location setObject:[NSString stringWithFormat:@"%f", cord.latitude] forKey:LATITUDE];
        [location setObject:[NSString stringWithFormat:@"%f", cord.longitude] forKey:LONGITUDE];
    }
    return cord;
}

- (id) init
{
    self = [super init];
    self.viewIdentifier = @"Pin";
    return self;
}

- (SSMapMarker *) changeTitle :(NSString *) newTitle
{
    self.title = newTitle;
    return self;
}

- (SSMapMarker *) changeSubtitle :(NSString *) newSubtitle
{
    self.subtitle = newSubtitle;
    return self;
}

+ (SSMapMarker *) getMarkerAt :(NSMutableDictionary *) location
{
    //BOOL markable = [location objectForKey:STREET_ADDRESS] && [location objectForKey:CITY] && [location objectForKey:STATE];
    //if (!markable)
    //{
    //    return nil;
    //}
    
   
    float latitude = [[location objectForKey:LATITUDE] floatValue];
    float longitude = [[location objectForKey:LONGITUDE] floatValue];
    
    if (latitude == 0 || longitude == 0)
    {
        return nil;
    }
    
    CLLocationCoordinate2D cord = {latitude, longitude};
    
    SSMapMarker *ann = [[SSMapMarker alloc] init];
    ann.entity = location;
    ann.title = [location objectForKey:TITLE];
    
    if (ann.title == nil)
    {
        ann.title = [location objectForKey:NAME];
    }
    ann.subtitle = [location objectForKey:DESC] ? [location objectForKey:DESC] : @"";
    ann.coordinate = cord;
    return ann;
}

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

+ (SSMapMarker *) getMarker :(id) location
{
    BOOL markable = [location objectForKey:STREET_ADDRESS] && [location objectForKey:CITY] && [location objectForKey:STATE];
    if (!markable)
    {
        return nil;
    }
    
    NSString *sLatitude = [location objectForKey:LATITUDE];
    float latitude = [sLatitude floatValue];
   
    NSString *sLongitude = [location objectForKey:LONGITUDE];
    float longitude = [sLongitude floatValue];
    
    CLLocationCoordinate2D cord = {latitude, longitude};
    
    if (latitude == 0.f)
    {
        cord = [self updateLocation:location];
    }
    
    SSMapMarker *ann = [[SSMapMarker alloc] init];
    
    ann.entity = location;
    ann.title = [location objectForKey:@"title"];
    if (ann.title == nil)
    {
         ann.title = [location objectForKey:@"name"];
    }
    ann.subtitle = [location objectForKey:@"desc"] ? [location objectForKey:@"desc"] : @"";
    ann.coordinate = cord;
    return ann;
}

@end
