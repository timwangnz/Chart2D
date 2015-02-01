//
//  RoundTextView.m
//  Medistory
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSRoundTextView.h"

@implementation SSRoundTextView

- (void) autofit
{
    if (!self.text || [self.text length] < 1)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
        return;
    }
    
    CGRect r = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 0)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:self.font ? self.font : [UIFont systemFontOfSize:15]}
                                        context:nil];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, r.size.height + 25);
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.cornerRadius = 6;
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
    float corner = self.cornerRadius == 0 ? 2 : self.cornerRadius;
    if (self.tag != 0)
    {
        corner = self.tag;
    }
    layer.cornerRadius = corner;
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    layer.masksToBounds = YES;
    
    [super drawRect: rect];
}

@end
