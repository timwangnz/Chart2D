//
//  RoundButton.m
// Appliatics
//
//  Created by Anping Wang on 9/18/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSRoundButton.h"

@implementation SSRoundButton

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
    float corner = self.cornerRadius == 0 ? 2 : self.cornerRadius;
    
    layer.cornerRadius = corner;
    layer.masksToBounds = YES;
    [super drawRect: rect];
}

@end
