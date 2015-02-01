//
//  WCMapTouchView.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/13/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SSMapTouchView : UIView
{
}

@property (strong, nonatomic) id delegate;

@property (assign) SEL callAtHitTest;

@end
