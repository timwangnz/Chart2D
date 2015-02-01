//
//  GeoCodeUtil.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/14/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface SSGeoCodeUtil : NSObject
{
    NSMutableDictionary *locationMap;
    CLGeocoder *geocoder;
}

+ (CLLocation *) getCurrentLocation;
+ (CLLocationCoordinate2D) getCurrentCoordinate;

- (CLLocationCoordinate2D) getCoordinates : (NSString *) address;
- (CLLocation *) getCurrentLocation;
-(CLLocationCoordinate2D) getCurrentCoordinate;
- (NSDictionary *) getCurrentAddress;
- (NSDictionary *) getAddressFromLatitude:(float) latitude longitude:(float) longitude;

@end
