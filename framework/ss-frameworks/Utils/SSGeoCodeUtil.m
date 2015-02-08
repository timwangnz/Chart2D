//
//  GeoCodeUtil.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/14/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSGeoCodeUtil.h"
#import "DebugLogger.h"
#import "SSJSONUtil.h"
#import "SSStorageManager.h"
#import <MapKit/MapKit.h>
#import "SSCommonVC.h"

#define STREET_ADDRESS @"street"
#define CITY @"city"
#define STATE @"state"
#define COUNTRY @"country"
#define POSTAL_CODE @"postalCode"
#define ZIP_CODE @"zipCode"
#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define STATUS @"status"

@implementation SSGeoCodeUtil

static NSString *GOOGLE_MAP_KEY = @"http://maps.google.com/maps/geo";
static NSString *GOOGLE_MAP_KEY_JSON = @"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false";
static NSString *GOOGLE_MAP_REVEASE_KEY_JSON = @"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false";

static CLLocationManager *locationManager;

+ (CLLocation *) getCurrentLocation
{
    return [[[SSGeoCodeUtil alloc]init] getCurrentLocation];
}

+ (CLLocationCoordinate2D) getCurrentCoordinate
{
    return [[[SSGeoCodeUtil alloc]init] getCurrentCoordinate];
}

-(CLLocationCoordinate2D) getCurrentCoordinate
{
    if(!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
    }
    
    CLLocationCoordinate2D newCenter = locationManager.location.coordinate;
    if(newCenter.latitude == 0)
    {
        newCenter = (CLLocationCoordinate2D) {37.782413, -122.40773};
    }
    return newCenter;
}

-(CLLocation *) getCurrentLocation
{
    if(!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
        [locationManager startUpdatingLocation];
    }
    
       return locationManager.location;
}

- (NSDictionary *) getCurrentAddress
{
    CLLocationCoordinate2D curretLoc = [self getCurrentCoordinate];
    return [self getAddressFromLatitude:curretLoc.latitude longitude:curretLoc.longitude];
}

- (NSDictionary *) getAddressFromLatitude:(float) latitude longitude:(float) longitude
{
    NSString *urlString = [NSString stringWithFormat: GOOGLE_MAP_REVEASE_KEY_JSON, latitude, longitude];
    
    NSError *error = nil;
    
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
    
    if(error != nil || locationString == nil)
    {
        DebugLog(@"Failed to get location string from Google %@", error);
        return nil;
    }
    else
    {
        NSDictionary *address = [locationString toDictionary];
        NSString *status = [address objectForKey:STATUS];
        if ([@"OK" isEqualToString:status])
        {
            NSDictionary *googleStreetAddress=nil;
            for (NSDictionary *result in [address objectForKey:@"results"])
            {
                NSArray * types = [result objectForKey:@"types"];
                for(NSString *type in types)
                {
                    if ([type isEqualToString : @"street_address"])
                    {
                        googleStreetAddress = result;
                        break;
                    }
                }
            }
            
            NSMutableDictionary *streetAddress = [[NSMutableDictionary alloc]init];
            NSArray *components = [googleStreetAddress objectForKey:@"address_components"];
           
            NSString *sNo = [self getComponentValue:@"street_number" from:components];
            NSString *streetName = [self getComponentValue:@"route" from:components];
            
            [streetAddress setObject: [NSString stringWithFormat:@"%@ %@", sNo, streetName] forKey:STREET_ADDRESS];
            [streetAddress setObject: [self getComponentValue:@"locality" from:components] forKey:CITY];
            [streetAddress setObject: [self getShortValue:@"administrative_area_level_1" from:components] forKey:STATE];
            [streetAddress setObject: [self getComponentValue:COUNTRY from:components] forKey:COUNTRY];
            [streetAddress setObject: [self getComponentValue:@"postal_code" from:components] forKey:POSTAL_CODE];
            [streetAddress setObject: [NSNumber numberWithFloat:latitude] forKey:LATITUDE];
            [streetAddress setObject: [NSNumber numberWithFloat:longitude] forKey:LONGITUDE];
            
            return streetAddress;
        }
        else
        {
            return nil;
        }
    }
}

- (NSString *) getShortValue : (NSString *) componentName from :(NSArray *) components
{
    for (NSDictionary *item in components)
    {
        NSArray * types = [item objectForKey:@"types"];
        for (NSString *type in types)
        {
            if ([componentName isEqualToString:type])
            {
                return [item objectForKey:@"short_name"];
            }
        }
    }
    return @"";
}
- (NSString *) getComponentValue : (NSString *) componentName from :(NSArray *) components
{
    for (NSDictionary *item in components)
    {
        NSArray * types = [item objectForKey:@"types"];
        for (NSString *type in types)
        {
            if ([componentName isEqualToString:type])
            {
                return [item objectForKey:@"long_name"];
            }
        }
    }
    return @"";
}

static int numberBeforeSave = 0;


- (CLLocationCoordinate2D) getCoordinates : (NSString *) address
{
    if (!locationMap)
    {
        NSDictionary *objectsStoredInCache = [[SSStorageManager storageManager] read : GOOGLE_MAP_KEY];
        if(objectsStoredInCache)
        {
            locationMap = [[NSMutableDictionary alloc]initWithDictionary:objectsStoredInCache];
        }
        else
        {
            locationMap = [[NSMutableDictionary alloc]init];
        }
    }
    
    NSString *locationString = [locationMap objectForKey:address];
    
    if (!locationString || [locationString isEqualToString:@"620,0,0,0"])
    {
        NSString *urlString = [NSString stringWithFormat: GOOGLE_MAP_KEY_JSON, address];
        NSError *error = nil;
        locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:&error];
        
        if(error != nil || locationString == nil)
        {
            DebugLog(@"Failed to get location string from Google for %@ due to %@", address, error);
            CLLocationCoordinate2D coord = {0, 0};
            [locationMap setObject:locationString forKey:address];
            return coord;
        }
        else
        {
            NSDictionary *googleAddress = [locationString toDictionary];
            NSString *status = [googleAddress objectForKey:@"status"];
            if ([@"OK" isEqualToString:status])
            {
                for (NSDictionary *result in [googleAddress objectForKey:@"results"])
                {
                    id geometry = [[result objectForKey:@"geometry"] objectForKey:@"location"];
                    locationString = [NSString stringWithFormat:@"%@,%@", [geometry objectForKey:@"lat"], [geometry objectForKey:@"lng"]];
                }
                
                [locationMap setObject:locationString forKey:address];
                
                if (numberBeforeSave >= 20)
                {
                    [[SSStorageManager storageManager] save : locationMap uri: GOOGLE_MAP_KEY];
                    numberBeforeSave = 0;
                }
                else
                {
                    numberBeforeSave ++;
                }
            }
        }
    }
    
    NSArray *elements = [locationString componentsSeparatedByString:@","];
    CLLocationCoordinate2D coord = {[[elements objectAtIndex:0] floatValue], [[elements objectAtIndex:1] floatValue]};
    return coord;
}


@end
