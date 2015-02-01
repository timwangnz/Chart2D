//
//  SSTutorApp.m
//  SixStreams
//
//  Created by Anping Wang on 2/1/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTutorApp.h"
#import "SSDrawableVC.h"
#import "SSBooksVC.h"
#import "SSProfileEditorVC.h"
#import "SSCommonSetupVC.h"
#import "SSConfigManager.h"
#import "SSFriendVC.h"
//#import "SSSplitVC.h"

@interface SSTutorApp ()
{ 
}
@end


@implementation SSTutorApp

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
    UITabBarController *tabbarCtrler = [[UITabBarController alloc]init];
    
    SSProfileEditorVC *pe = [[SSProfileEditorVC alloc]init];
    pe.tabBarItem.title = @"Profile";
    [pe editMyProfile];
    
    SSConfigManager *configMgr = [SSConfigManager getConfigMgr] ;
    if([[configMgr getConfiguration] count] ==0)
    {
        [configMgr setValue:@"mm/dd/yyyy" ofType:@"string" at:3 isSecret:NO for:@"Date Format" ofGroup:@"Personal"];
        [configMgr setValue:@"hh:mm a" ofType:@"string" at:2 isSecret:NO for:@"Time Fomrat" ofGroup:@"Personal"];
        [configMgr setValue:@"Ok" ofType:@"string" at:0 isSecret:NO for:@"Status" ofGroup:@"General"];
        [configMgr setValue:@"YES" ofType:@"boolean" at:1 isSecret:NO for:@"Customizable" ofGroup:@"General"];
        [configMgr save];
    }
  
    SSFriendVC *friendsVC = [[SSFriendVC alloc]init];
    friendsVC.title = @"Friends";
    friendsVC.findAllowed = YES;
    friendsVC.tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    
    SSBooksVC *rootNav = [[SSBooksVC alloc]init];
    [rootNav refresh];
    
    [tabbarCtrler addChildViewController:[[UINavigationController alloc]initWithRootViewController: rootNav]];
    [tabbarCtrler addChildViewController:[[UINavigationController alloc]initWithRootViewController: friendsVC]];
    [tabbarCtrler addChildViewController:[[UINavigationController alloc]initWithRootViewController: pe]];

    SSDrawableVC *detailNav = [[SSDrawableVC alloc] init];
    rootNav.detailVC = detailNav;
    detailNav.delegate = rootNav;
   
    self.displayName = @"Tutor";
    UIViewController *root;
    if([self isIPad])
    {
        UISplitViewController *splitVC = [[UISplitViewController alloc] init];
        splitVC.viewControllers = [NSArray arrayWithObjects:
                            tabbarCtrler,detailNav
                            //[[UINavigationController alloc]initWithRootViewController: detailNav]
                            , nil];
        splitVC.delegate = detailNav;
        [splitVC setValue:[NSNumber numberWithFloat:250.0] forKey:@"_masterColumnWidth"];
 
        detailNav.svc = splitVC;
        root = splitVC;
    }
    else{
        root = tabbarCtrler;
    }
    return root;
}

- (id) init
{
    self = [super init];
    if (self)
    {
       
        self.displayName = @"iTutor";
        NSDictionary *jobTitles = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Tutor", @"Tutor",
                                   @"Student", @"Student",
                                   @"Admin", @"Admin",
                                   nil];
        
        NSDictionary *group = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"None", @"None",
                               @"Middle Scholl", @"Middle School",
                               @"Hight School", @"High School",
                               @"Elementary School", @"Elementar School",
                               @"Other", @"Other",
                               nil];
        
        [lovs setObject:group forKey:GROUPS];
        [lovs setObject:jobTitles forKey:JOB_TITLE];
    }
    return self;
}


- (NSDictionary *) getLov:(NSString *)attrName ofType:(NSString *)objectType
{
    NSDictionary *lov = [lovs objectForKey:attrName];
    return lov ? lov : [NSDictionary dictionary];
}

@end
