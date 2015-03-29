//
//  WCSecondViewController.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SSMarkerView.h"
#import "SSMapMarker.h"
#import "SSSearchVC.h"

@protocol SSNearByDelegate <NSObject>
@optional
- (void) mapView:(id) view didSelect : (id) item;
- (NSString *) mapView:(id) view titleFor : (id) item;
- (NSString *) mapView:(id) view subtitleFor : (id) item;
- (id) mapView:(id) view addressFor:(id) item;
- (void) mapView:(id) view didDeviceMove: (CLLocation *)userLocation;
@end

@interface SSNearByVC : SSSearchVC<MKMapViewDelegate>
{
    IBOutlet MKMapView *myMapView;
}

@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) id<SSNearByDelegate> delegate;
@property (nonatomic) BOOL showDeviceLoc;
@property (nonatomic) BOOL trackDevice;
@property float deltaLatitude;
@property float deltaLongitude;
@property BOOL searchAllowed;

- (void) assignPlaces;
- (void) searchCurrentLocation;

@end
