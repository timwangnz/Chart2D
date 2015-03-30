//
//  CoreCrmAppDelegate.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 11/16/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//

#import "Chart2DSampleApp.h"


#import "Graph2DVC.h"

@implementation Chart2DSampleApp


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   
    
    self.graph2DVC = [[Graph2DVC alloc] initWithNibName:@"Graph2DVC" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.graph2DVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
