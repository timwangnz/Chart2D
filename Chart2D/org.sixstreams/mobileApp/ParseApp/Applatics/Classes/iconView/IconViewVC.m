//
//  IconViewVC.m
// AppliaticsMobile
//
//  Created by Anping Wang on 3/31/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "IconViewVC.h"
#import "AttributeValue.h"

@interface IconViewVC ()

@end

@implementation IconViewVC


-(IBAction)onSelect:(id)sender
{
    if (self.iconViewDelegate != nil)
    {
        [self.iconViewDelegate onSelect:sender object: self.userInfo];
    }
}

- (void) setViewBG:(UIColor *)viewBG
{
    _viewBG = viewBG;
    labelView.backgroundColor = viewBG;
}

- (int) getLevel
{
    if (self.parentIconView == nil) {
        return 0;
    }
    
    if (self.parentIconView) {
        return [self.parentIconView getLevel] + 1;
    }
    return 0;
}

-(CGPoint) getCenter
{
    CGRect rect = self.view.frame;
    return CGPointMake((int) (rect.origin.x + rect.size.width/2), (int) (rect.origin.y + rect.size.height / 2));
}

- (void) addChild:(id) child
{
    if(children==nil)
    {
        children = [[NSMutableArray alloc]init];
    }
    [children addObject:child];
}

-(NSArray *) getChildren
{
    return children;
}

- (void) updateUI
{
    textLabel.text = self.label;
    subtitleLabel.text = self.subtitle;
    subtitleLabel.hidden = !self.subtitle;
    
    indicator.hidden = YES;
    if (_badges > 0)
    {
        [indicator setTitle:[NSString stringWithFormat:@"%d", self.badges] forState:UIControlStateNormal];
        [indicator setNeedsDisplay];
        [indicator setBackgroundImage:[UIImage imageNamed:@"indicator.png"] forState:UIControlStateNormal];
    }
    
    indicator.hidden = self.badges == 0;
    
    imageView.url = self.imageUrl;
    
    shadowImg.hidden = YES;
    if (self.badges < 0) {
        [indicator setBackgroundImage:[UIImage imageNamed:@"indicator-new.png"] forState:UIControlStateNormal];
    }
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

@end
