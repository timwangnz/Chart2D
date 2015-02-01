//
//  TreeNodeIconVC.m
// Appliatics2
//
//  Created by Anping Wang on 5/3/13.
//  Copyright (c) 2013 s. All rights reserved.
//

#import "TreeNodeIconVC.h"

@interface TreeNodeIconVC ()

@end

@implementation TreeNodeIconVC


- (void) updateUI
{
    textLabel.text = self.label;
    subtitleLabel.text = self.subtitle;
    subtitleLabel.hidden = !self.subtitle;
    
    indicator.hidden = YES;
    if (self.badges > 0)
    {
        [indicator setTitle:[NSString stringWithFormat:@"%d", (int)self.badges] forState:UIControlStateNormal];
        [indicator setNeedsDisplay];
        [indicator setBackgroundImage:[UIImage imageNamed:@"indicator.png"] forState:UIControlStateNormal];
    }
    
    indicator.hidden = self.badges == 0;
    
    float size = self.iconSize.height - 30;
    float iconWidth = self.iconSize.width - 30;
    
    imageView.frame = CGRectMake(2, 2, size - 4, size - 4);
    
    imageView.defaultImg = [UIImage imageNamed:[self.imageUrl lowercaseString]];
    if (imageView.defaultImg == nil || self.mode == 0) {
        imageView.defaultImg = [UIImage imageNamed:self.imageUrl];
        if (imageView.image == nil)
        {
            imageView.image = [UIImage imageNamed:@"person.png"];
        }
    }
    
    
    if (self.mode == 3)
    {
        [indicator setBackgroundImage:[UIImage imageNamed:@"indicator-green.png"] forState:UIControlStateNormal];
    }
    else
    {
        [indicator setBackgroundImage:[UIImage imageNamed:@"indicator.png"] forState:UIControlStateNormal];
    }
    
    innerView.frame = CGRectMake(innerView.frame.origin.x, innerView.frame.origin.y, innerView.frame.size.width, size);
    
    innerView.backgroundColor = [UIColor colorWithRed:225./255 green:225./255 blue:225./255 alpha:1];
    labelView.frame = CGRectMake(size ,0, iconWidth - size , innerView.frame.size.height);
    
    BOOL lowinfluencePeople = self.tag <=0;
    
    if (![labelView.backgroundColor isEqual: innerView.backgroundColor]) {
        subtitleLabel.textColor = [UIColor blackColor];
        sentiment.textColor = [UIColor blackColor];
    }
    else
    {
        subtitleLabel.textColor = [UIColor blackColor];
        sentiment.textColor = [UIColor blackColor];
    }
    sentiment.hidden = self.mode == 0 || lowinfluencePeople;
    sentiment.text = self.sentimentLabel;
    
    if(sentiment.hidden)
    {
        textLabel.frame = CGRectMake(10, 10, labelView.frame.size.width - 20, textLabel.frame.size.height);
        
        subtitleLabel.frame = CGRectMake(10, 30, textLabel.frame.size.width, subtitleLabel.frame.size.height);
    }
    else {
        textLabel.frame = CGRectMake(10, 5, labelView.frame.size.width - 20, textLabel.frame.size.height);
        
        subtitleLabel.frame = CGRectMake(10, 25, textLabel.frame.size.width, subtitleLabel.frame.size.height);
        
        sentiment.frame = CGRectMake(10, 42, textLabel.frame.size.width, subtitleLabel.frame.size.height);
        
    }
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.iconSize.width, self.iconSize.height);
    shadowImg.frame = CGRectMake(innerView.frame.origin.x, innerView.frame.origin.y, innerView.frame.size.width + 6, innerView.frame.size.height + 8);
    shadowImg.hidden = NO;
}

@end
