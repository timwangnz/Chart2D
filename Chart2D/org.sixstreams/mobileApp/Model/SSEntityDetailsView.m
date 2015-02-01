//
//  SSJobDetailsView.m
//  JobsExchange
//
//  Created by Anping Wang on 2/3/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSEntityDetailsView.h"


@implementation SSEntityDetailsView

- (void) configureUI
{
    
}

- (UIViewController *) controllerAtPage:(NSUInteger)page
{
    UIViewController *pageCtrl = [propertyVCs objectAtIndex:page];
    self.parentVC.title = pageCtrl.title;
    return pageCtrl;
}

- (NSUInteger) getPages
{
    return [propertyVCs count];
}

- (void) updateUI:(UIViewController *)page
{
    if (page)
    {
        self.parentVC.title = page.title;
    }
}

@end
