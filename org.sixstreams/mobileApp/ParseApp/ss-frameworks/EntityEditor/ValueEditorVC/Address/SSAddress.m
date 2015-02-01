//
//  SSAddress.m
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSAddress.h"
#import "SSCommonVC.h"
#import <MapKit/MapKit.h>
#import "SSGeoCodeUtil.h"
#import "DebugLogger.h"

@implementation SSAddress

- (id) initWithDictionary:(NSDictionary *) data
{
    self = [super init];
    if ([data isKindOfClass:[NSDictionary class]]) {
        
        self.state = [data valueForKey:STATE];
        self.city = [data valueForKey:CITY];
        self.country = [data valueForKey:COUNTRY];
        self.zipCode = [data valueForKey:ZIP_CODE];
        self.street = [data valueForKey:STREET_ADDRESS];
        self.location = [data valueForKey:LOCATION];
        self.longitude = [[data valueForKey:LONGITUDE] floatValue];
        self.latitude = [[data valueForKey:LATITUDE] floatValue];
        if(!self.country)
        {
            self.country = @"USA";
        }
    }
    return self;
}

- (void) updateLocation
{
    
    BOOL markable = self.street && self.city && self.state;
    
    if (!markable)
    {
        return;
    }
    CLLocationCoordinate2D cord = {0, 0};
    NSString * theAddress = [NSString stringWithFormat:@"%@, %@, %@",
                             self.street,
                             self.city,
                             self.state];
    
    
    cord = [[[SSGeoCodeUtil alloc]init] getCoordinates:[theAddress stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    if (cord.latitude == 0.0f)
    {
        DebugLog(@"Failed to decode %@", theAddress);
    }
    else
    {
        self.latitude =  cord.latitude;
        self.longitude =  cord.longitude;
    }
}

- (NSDictionary *) dictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.state forKey:STATE];
    [dic setValue:self.city forKey:CITY];
    [dic setValue:self.street forKey:STREET_ADDRESS];
    [dic setValue:self.country forKey:COUNTRY];
    [dic setValue:self.zipCode forKey:ZIP_CODE];
    [dic setValue:self.location forKey:LOCATION];
    [dic setObject:[NSNumber numberWithFloat:self.longitude] forKey:LONGITUDE];
    [dic setObject:[NSNumber numberWithFloat:self.latitude] forKey:LATITUDE];
    return dic;
}

- (NSString *) description
{
    NSMutableString *address = [[NSMutableString alloc]init];
    
    if (!self.street) {
        return @"";
    }
    
    if (self.location && [self.location length] != 0) {
        [address appendFormat:@"%@, %@ %@", self.location,self.street, self.city];
    }
    else
    {
        [address appendFormat:@"%@ %@", self.street, self.city];
    }
       return address;
}

- (NSString *) longDesc
{
    NSMutableString *address = [[NSMutableString alloc]init];
    if (!self.street) {
        return @"";
    }
    [address appendFormat:@"%@, %@ %@, %@ %@, %@",
     self.location, self.street,self.city,self.state, self.zipCode, self.country];
    return address;
}

@end
