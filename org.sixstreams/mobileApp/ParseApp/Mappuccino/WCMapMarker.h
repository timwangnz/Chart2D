//
//  WCMapMarker.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/18/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface WCMapMarker : NSObject <MKAnnotation> {
    
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSDictionary *roaster;

+ (WCMapMarker *) getMarker :(NSDictionary *) roaster;
+ (WCMapMarker *) getMyMarker;

@end
