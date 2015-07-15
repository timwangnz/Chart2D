//
//  CoreCrmAppDelegate.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/16/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import "Chart2DSampleApp.h"


#import "Graph2DVC.h"
#import "BarChartTestVC.h"

@implementation Chart2DSampleApp


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   
    
    UIViewController *graph2DVC = [[BarChartTestVC alloc]init];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:graph2DVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
