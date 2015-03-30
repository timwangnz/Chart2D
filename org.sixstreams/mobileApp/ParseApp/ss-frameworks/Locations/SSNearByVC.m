//
//  WCSecondViewController.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "SSNearByVC.h"
#import "SSMapMarker.h"
#import "SSGeoCodeUtil.h"
#import "DebugLogger.h"
#import "SSFilter.h"
#import "SSMapMarker.h"
#import "SSEntityEditorVC.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface SSNearByVC ()<CLLocationManagerDelegate>
{
    IBOutlet UIButton *btnSearchHere;
    CLLocationManager *locationManager;
    SSMapMarker *deviceMarker;
    BOOL scaled;
    float xmax;
    float ymax;
    float xmin;
    float ymin;
    NSMutableArray *anns;
    NSDate *refreshedAt;
    CLLocation *pastLocation;
}


@end

@implementation SSNearByVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Near By", @"Near By");
        [self.tabBarItem setImage: [[UIImage imageNamed:@"27-planet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        self.searchAllowed = YES;
        self.orderBy = NAME;
        self.subtitleKey = DESC;
        self.titleKey = NAME;
        self.ascending = YES;
        self.limit = 40;
    }
    return self;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] >= 1)
    {
        CLLocation *location = (CLLocation *)locations[0];
        
        if(!pastLocation)
        {
            pastLocation = location;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pastLocation.coordinate, 800, 800);
            [myMapView setRegion:[myMapView regionThatFits:region] animated:YES];
        }
        
        CLLocationDistance distance = [location distanceFromLocation:pastLocation];
        //self.title = [NSString stringWithFormat:@"%f", distance];
        if (deviceMarker && distance > 5)
        {
            [self moveAnnotation:deviceMarker to:location.coordinate];
            pastLocation = location;
        }
        
        
        if ([self.delegate respondsToSelector:@selector(mapView:didDeviceMove:)])
        {
            [self.delegate mapView:self didDeviceMove:location];
        }
    }
}

- (void) moveAnnotation:(SSMapMarker*)annotation to : (CLLocationCoordinate2D) newLocation
{
    [UIView animateWithDuration:1.0f
                     animations:^(void){
                         annotation.coordinate = newLocation;
                     }
                     completion:^(BOOL finished){
                        
                     }
     ];
}

- (IBAction)searchHear:(id)sender
{
    [self rangeQuery];
    [self forceRefresh];
}

- (void) searchCurrentLocation
{
    MKCoordinateRegion region = {{0,0},{0,0}};
    region.span.latitudeDelta = self.deltaLatitude == 0 ? 10 : self.deltaLatitude;
    region.span.longitudeDelta = self.deltaLongitude == 0 ? 10 :self.deltaLongitude;
    region.center = [[[SSGeoCodeUtil alloc]init] getCurrentCoordinate];
    [myMapView setRegion:region];
    [self.predicates removeAllObjects];
    [self.predicates addObject:[SSFilter on:LATITUDE op:GREATER value: [NSNumber numberWithFloat:(region.center.latitude - region.span.latitudeDelta/2)]]];
    [self.predicates addObject:[SSFilter on:LATITUDE op:LESS value: [NSNumber numberWithFloat:(region.center.latitude + region.span.latitudeDelta/2)]]];
    [self.predicates addObject:[SSFilter on:LONGITUDE op:GREATER value: [NSNumber numberWithFloat:(region.center.longitude - region.span.longitudeDelta/2)]]];
    [self.predicates addObject:[SSFilter on:LONGITUDE op:LESS value: [NSNumber numberWithFloat:(region.center.longitude + region.span.longitudeDelta/2)]]];
}


- (void) rangeQuery
{
    CGPoint nePoint = CGPointMake(myMapView.bounds.origin.x + myMapView.bounds.size.width, myMapView.bounds.origin.y);
    CGPoint swPoint = CGPointMake((myMapView.bounds.origin.x), (myMapView.bounds.origin.y + myMapView.bounds.size.height));
    
    CLLocationCoordinate2D neCoord = [myMapView convertPoint:nePoint toCoordinateFromView:myMapView];
    CLLocationCoordinate2D swCoord = [myMapView convertPoint:swPoint toCoordinateFromView:myMapView];
    
    CLLocationCoordinate2D currentLocation = (CLLocationCoordinate2D) {(neCoord.latitude + swCoord.latitude)/2, (neCoord.longitude + swCoord.longitude)/2};
    CLLocationDegrees latitudeDelta = fabs(neCoord.latitude - swCoord.latitude);
    CLLocationDegrees longitudeDelta = fabs(neCoord.longitude - swCoord.longitude);
    
    [self.predicates removeAllObjects];
    [self.predicates addObject:[SSFilter on:LATITUDE op:GREATER value: [NSNumber numberWithFloat:(currentLocation.latitude - latitudeDelta/2)]]];
    [self.predicates addObject:[SSFilter on:LATITUDE op:LESS value: [NSNumber numberWithFloat:(currentLocation.latitude + latitudeDelta/2)]]];
    [self.predicates addObject:[SSFilter on:LONGITUDE op:GREATER value: [NSNumber numberWithFloat:(currentLocation.longitude - longitudeDelta/2)]]];
    [self.predicates addObject:[SSFilter on:LONGITUDE op:LESS value: [NSNumber numberWithFloat:(currentLocation.longitude + longitudeDelta/2)]]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    btnSearchHere.hidden = !self.searchAllowed;
    if (self.showDeviceLoc)
    {
        [self assignPlaces];
        myMapView.showsUserLocation = YES;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    [locationManager startUpdatingLocation];

    [self searchCurrentLocation];
}

- (void) viewDidLoad
{
    //[super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    locationManager.delegate = self;
    
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    
   deviceMarker = [SSMapMarker getMyMarker];

   
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    for (id ann in anns)
    {
        [myMapView addAnnotation:ann];
    }
}

- (void) refresh
{
    if (refreshedAt == nil)
    {
        [self forceRefresh];
        refreshedAt = [NSDate date];
    }
}

- (void) onDataReceived:(id) objects
{
    [super onDataReceived:objects];
    if([objects count] > 0)
    {
        [self assignPlaces];
    }
}

- (void) assignPlaces
{
    [myMapView removeAnnotations:myMapView.annotations];
    anns = [NSMutableArray array];
    if([self.objects count] > 0)
    {
        xmax = -1111111110;
        ymax = -1111111110;
        xmin = 1111111110;
        ymin = 1111111110;
        
        for (id item in self.objects)
        {
            id address =[self objectToLoc:item];
            if(self.delegate)
            {
                address = [self.delegate mapView:self addressFor:item];
            }
            
            if (address)
            {
                SSMapMarker *ann = [SSMapMarker getMarkerAt : address];
                if (ann && ann.coordinate.latitude != 0)
                {
                    float x = ann.coordinate.latitude;
                    float y = ann.coordinate.longitude;
                    xmax = x > xmax ? x : xmax;
                    xmin = x < xmin ? x : xmin;
                    ymax = y > ymax ? y : ymax;
                    ymin = y < ymin ? y : ymin;
                    CLLocationCoordinate2D cord = {x, y};
                    ann.coordinate = cord;
                    ann.title = [self objectTitle:item];
                    ann.entity = item;
                    ann.subtitle = [self objectSubtitle:item];
                    [anns addObject:ann];
                }
            }
        }
    }
    else
    {
        scaled = YES;
    }
    if (self.showDeviceLoc && ![anns containsObject:deviceMarker])
    {
        [anns addObject:deviceMarker];
    }
    if([anns count] > 0)
    {
        if(!scaled)
        {
            MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
            region.span.longitudeDelta =  ymax - ymin;
            region.span.latitudeDelta = xmax - xmin;
            if ([self.objects count] <= 1) {
                region.span.longitudeDelta =  0.2;
                region.span.latitudeDelta = 0.2;
            }
            region.center = (CLLocationCoordinate2D){(xmax+xmin)/2, (ymax+ymin)/2};
            [myMapView setRegion:region animated:YES];
            scaled = YES;
        }
        else
        {
            for (id ann in anns)
            {
                [myMapView addAnnotation:ann];
            }
        }
    }
}

//Delegate
- (void) showDetails:(UIButton *) sender
{
    id item = [self.objects objectAtIndex:sender.tag];
    if(self.delegate)
    {
        [self.delegate mapView:self didSelect:item];
    }
    else{
        Class vcClass = NSClassFromString(self.entityDetailsClass);
        SSEntityEditorVC *childVC = [[vcClass alloc] init];
        childVC.item2Edit = [self.objects objectAtIndex:((UIButton*)sender).tag];
        childVC.itemType = self.objectType;
        childVC.readonly = YES;
        [self showPopup:childVC sender:self];
    }
}

-(NSString *) objectTitle:(id) item
{
    if(self.delegate)
    {
        return [self.delegate mapView:self titleFor:item];
    }
    return item ? [item objectForKey:self.titleKey] : @"";
}


-(id) objectToLoc:(id) item
{
    id address = [item objectForKey:ADDRESS];
    if (!address)
    {
        if ([item objectForKey:LATITUDE]) {
            return item;
        }
        return nil;
    }
    return address;
}

- (NSString *) objectSubtitle:(id) item
{
    if(self.delegate)
    {
        return [self.delegate mapView:self subtitleFor:item];
    }
    return item ? [item objectForKey:self.subtitleKey] : @"";
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[SSMapMarker class]])
    {
        SSMapMarker *marker = (SSMapMarker*) annotation;
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:marker.viewIdentifier];
        if (!pinView)
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:marker.viewIdentifier];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
        }
        else
        {
            pinView.annotation = annotation;
        }
        
        UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
        rightButton.tag = [self.objects indexOfObject:marker.entity];
        [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = rightButton;
        return pinView;
        
    }
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
