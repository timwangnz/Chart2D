//
//  SSFredApp.m
//  SixStreams
//
//  Created by Anping Wang on 1/16/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSFredApp.h"
#import "SSFredVC.h"
#import "SSTimeSeriesGraphVC.h"

@implementation SSFredApp

- (NSString *) appId
{
    return @"V7gYojS51a1lCsurnjEYWc9qQyHP14Y9p9pyuE9B";
}
- (NSString *) appKey
{
    return @"bdY8rxK3hoJVliiSx9HWEjeF7QV0TM7Yn9XrvdUC";
}

- (UIViewController *) createRootVC
{
    self.displayName = @"Fred";
    
    UIViewController *root = nil;
    
    if([self isIPad])
    {
        UISplitViewController *splitVC = [[UISplitViewController alloc] init];
        SSFredVC *rootNav = [[SSFredVC alloc]init];
        SSTimeSeriesGraphVC *detailNav = [[SSTimeSeriesGraphVC alloc] init];
        
        splitVC.viewControllers = [NSArray arrayWithObjects:
                                [[UINavigationController alloc]initWithRootViewController: rootNav],
                                [[UINavigationController alloc]initWithRootViewController: detailNav], nil];
        
        splitVC.delegate = detailNav;
        rootNav.detailVC = detailNav;
        root = splitVC;
    }
    else{
        SSFredVC *rootNav = [[SSFredVC alloc]init];
        root = [[UINavigationController alloc]initWithRootViewController: rootNav];
        SSTimeSeriesGraphVC *detailNav = [[SSTimeSeriesGraphVC alloc] init];
        rootNav.detailVC = detailNav;
    }
    
    return root;

    
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.isPublic = YES;
    }
    return self;
}

@end
