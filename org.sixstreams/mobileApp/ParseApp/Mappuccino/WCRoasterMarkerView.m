//
//  WCRoasterMarkerView.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/13/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCRoasterMarkerView.h"

@implementation WCRoasterMarkerView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil) {
       	self.image = [UIImage imageNamed:@"53-house.png"];
        
      //  CGPoint notNear = CGPointMake(10000.0,10000.0);
      //  self.calloutOffset = notNear;
    }
    return self;
}


@end
