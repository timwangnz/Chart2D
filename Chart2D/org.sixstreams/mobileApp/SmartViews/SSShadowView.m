//
//  SSShadowView.m
//  SixStreams
//
//  Created by Anping Wang on 5/22/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSShadowView.h"

@implementation SSShadowView

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    layer.masksToBounds = NO;
    layer.cornerRadius = self.cornerRadius;
    layer.shadowOffset = CGSizeMake(10,12);
    layer.shadowRadius = 2;
    layer.shadowOpacity = 1;
    
    [super drawRect: rect];
    
}
@end
