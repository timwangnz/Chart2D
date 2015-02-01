//
//  RoundView.m
//  iSwim2.0
//
//  Created by Anping Wang on 4/23/11.
//  Copyright 2011 s. All rights reserved.
//

#import "SSRoundView.h"
#import "SSRoundTextView.h"


@implementation SSRoundView

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
   float corner = self.cornerRadius == 0 ? 2 : self.cornerRadius;
    
    layer.cornerRadius = corner;

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    layer.masksToBounds = YES;

    [super drawRect: rect];
    
}

- (void) autofit
{
    float height = 0;
    for(UIView *childView in self.subviews)
    {
        if ([childView isKindOfClass:[SSRoundTextView class]])
        {
            SSRoundTextView *editor = (SSRoundTextView *)childView;
            if (!editor.isEditable)
            {
                [(SSRoundTextView *)childView autofit];
            }
        }
        if ([childView isKindOfClass:[SSRoundView class]])
        {
            //[(SSRoundView *)childView autofit];
        }
    }
    for(UIView *childView in self.subviews)
    {
        if (!childView.hidden && childView.frame.origin.y + childView.frame.size.height  > height)
        {
            height  = childView.frame.origin.y + childView.frame.size.height;
        }
    }
    if (height > 0)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height + 6);
    }
}

@end
