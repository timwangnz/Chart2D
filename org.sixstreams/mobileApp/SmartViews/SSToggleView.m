//
//  SSToggleView.m
//  SixStreams
//
//  Created by Anping Wang on 2/13/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSToggleView.h"

@implementation SSToggleView


- (IBAction) toggleOptions:(UIButton *)sender
{
    UIView *parent = sender.superview;
    
    CGRect rect = parent.frame;
    
    int iconSize = 36;
    int edge = 0;
    
    NSUInteger numberOfChildren = [parent.subviews count];
    
    if (rect.size.width < (numberOfChildren) * iconSize)
    {
        rect.size.width = (numberOfChildren) * iconSize + 2*edge;
    }
    else
    {
        rect.size.width = iconSize;
    }
    
    rect.origin.x = self.frame.size.width - rect.size.width;
    
    parent.frame = rect;
    
    if (rect.size.width > iconSize)
    {
        for(UIView *child in parent.subviews)
        {
            
            rect = child.frame;
            child.hidden=NO;
            rect.origin.x = edge + iconSize*(child.tag);
            child.frame = rect;
        }
    }
    else
    {
        for(UIView *child in parent.subviews)
        {
            if ([child isEqual:sender]) {
                continue;
            }
            child.hidden=YES;
        }
        rect = sender.frame;
        rect.origin.x = 0;
        sender.frame = rect;
    }
    
    [parent setNeedsDisplay];
}


@end
