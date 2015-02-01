//
//  SSAddressVC.m
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSAddressVC.h"
#import "SSGeoCodeUtil.h"
#import "SSMapMarker.h"
#import "SSValueField.h"
#import "SSLovTextField.h"

@interface SSAddressVC () <UITextFieldDelegate>
{
    IBOutlet UITextField *tfCountry;
    IBOutlet UITextField *tfZipCode;
    IBOutlet UITextField *tfState;
    IBOutlet UITextField *tfCity;
    IBOutlet UITextField *tfStreet;
    IBOutlet UITextField *tfLoation;
    float longitude;
    float latitude;
    IBOutlet MKMapView *mapView;
}

- (IBAction)getCurrentAddress:(id)sender;

@end

@implementation SSAddressVC

- (IBAction)save:(id)sender
{
    SSAddress *address = [[SSAddress alloc]init];
    address.city = tfCity.text;
    address.state = tfState.text;
    address.street = tfStreet.text;
    address.country = tfCountry.text;
    address.zipCode = tfZipCode.text;
    address.location = tfLoation.text;
    [address updateLocation];
    self.field.value = [address dictionary];
    [super save:sender];

}

- (BOOL) entityShouldSave:(id) object
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) updateMap
{
    if (latitude != 0)
    {
        [mapView removeAnnotations:mapView.annotations];
        CLLocationCoordinate2D cord = {latitude, longitude};
        SSMapMarker *ann = [[SSMapMarker alloc] init];
        ann.coordinate = cord;
        [mapView addAnnotation:ann];
        
        MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
        float longitudeDelta = 0.03;
        float latitudeDelta = 0.03;
        
        region.span.longitudeDelta =  longitudeDelta * 2;
        region.span.latitudeDelta = latitudeDelta * 2;
        
        region.center = cord;
        [mapView setRegion:region animated:YES];
    }
}


- (IBAction)getCurrentAddress:(id)sender
{
    SSGeoCodeUtil *geoUtil = [[SSGeoCodeUtil alloc]init];
    
    NSDictionary *address = [geoUtil getCurrentAddress];
    tfStreet.text = [address objectForKey:STREET_ADDRESS];
    tfCity.text = [address objectForKey:CITY];
    tfState.text = [address objectForKey:STATE];
    tfCountry.text = [address objectForKey:COUNTRY];
    tfZipCode.text = [address objectForKey:POSTAL_CODE];
    tfLoation.text = [address objectForKey:LOCATION];
    longitude = [[address objectForKey:LONGITUDE] floatValue];
    latitude = [[address objectForKey:LATITUDE] floatValue];
    [self updateMap];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SSAddress *address = [[SSAddress alloc]initWithDictionary: self.field.value];
    if (self.navigationController)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    }
    tfCountry.text = address.country;
    tfCity.text = address.city;
    tfState.text = address.state;
    tfStreet.text = address.street;
    tfZipCode.text = address.zipCode;
    tfLoation.text = address.location;
    latitude = address.latitude;
    longitude = address.longitude;
    [self updateMap];
}

@end
