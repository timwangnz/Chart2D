//
//  WCMarkerView.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/13/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface WCMarkerView : MKAnnotationView
{
    IBOutlet UILabel *name;
    IBOutlet UILabel *address;
}

@property (nonatomic, strong) IBOutlet UILabel* name;


@property (nonatomic, strong) IBOutlet UILabel* address;



- (void) setRoaster:(id) roaster;
@end
