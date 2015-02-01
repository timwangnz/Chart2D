//
//  SSMapView.m
//  SixStreams
//
//  Created by Anping Wang on 8/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSMapView.h"

@implementation SSMapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSLog(@"%@", NSStringFromCGRect(self.layer.frame));
}


@end
