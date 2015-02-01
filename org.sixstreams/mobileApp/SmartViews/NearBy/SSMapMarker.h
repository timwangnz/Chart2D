//
//  SSMapMarker
//  
//
//  Created by Anping Wang on 9/18/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface SSMapMarker : NSObject <MKAnnotation> 
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString  *viewIdentifier;
@property (nonatomic, strong) NSDictionary *entity;

+ (SSMapMarker *) getMarkerAt :(NSDictionary *) location;
+ (SSMapMarker *) getMyMarker;

+ (CLLocationCoordinate2D) updateLocation :(NSMutableDictionary *) location;

- (SSMapMarker *) changeTitle :(NSString *) newTitle;
- (SSMapMarker *) changeSubtitle :(NSString *) newTitle;

@end
