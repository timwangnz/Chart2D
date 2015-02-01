//
//  WCRoasterDetailsVC.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 9/18/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "WCMapMarker.h"
#import "SSEntityEditorVC.h"
enum {
    SSViewEntity=0,
    SSCreateEntity,
    SSEditEntity
};
typedef NSUInteger SSEntityAction;

@interface WCRoasterDetailsVC : SSEntityEditorVC

@property SSEntityAction action;

- (IBAction)openWeb:(id)sender;
- (IBAction)makeCall:(id)sender;

@end
