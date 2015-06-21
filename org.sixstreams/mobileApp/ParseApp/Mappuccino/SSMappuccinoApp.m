//
//  SSMappuccinoApp.m
//  SixStreams
//
//  Created by Anping Wang on 12/7/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSMappuccinoApp.h"
#import "SSProfileEditorVC.h"
#import "WCHomeVC.h"
#import "WCByCityVC.h"
#import "SSNearByVC.h"
#import "WCSetupVC.h"
#import "SSSearchVC.h"
#import "SSCommonSetupVC.h"
#import "SSConfigManager.h"
#import "SSJobEditorVC.h"
#import "SSSecurityVC.h"
#import "SSProfileVC.h"
#import "WCRoasterCell.h"
#import "SSHighlightsVC.h"
#import "WCRoasterDetailsVC.h"
#import "SSSpotlightView.h"
#import "SSFollowVC.h"

@interface SSMappuccinoApp ()<SSTableViewVCDelegate>


@end


@implementation SSMappuccinoApp

- (NSString *) appId
{
    return @"GfJ6tRoxgAGobcckYFSAsr04f2KdkdEFbCsa88fJ";
}
- (NSString *) appKey
{
    return @"TJQvaYAKd3BvTBnur6PGi2rNLaB8YIB72NPVfbJB";
}

- (UIView *) backgroundView
{
    UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iOS-7-Wallpaper-Download.png"]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    return background;
}

- (UIViewController *) createRootVC
{
    UITabBarController *tabbarCtrler = [[UITabBarController alloc]init];
    
    [tabbarCtrler addChildViewController: [[UINavigationController alloc] initWithRootViewController:[[WCHomeVC alloc] init] ]];
    
    SSHighlightsVC *highlightsVC =[[SSHighlightsVC alloc]init];
    highlightsVC.objectType = COMPANY_CLASS;
    
    [highlightsVC.tabBarItem setImage: [[UIImage imageNamed:@"02-redo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    highlightsVC.tabBarItem.title = @"Spotlights";
    
   // [tabbarCtrler addChildViewController: [[UINavigationController alloc] initWithRootViewController:highlightsVC]];
    
    SSSearchVC *searchVC = [[SSSearchVC alloc]init];
    
    searchVC.objectType = COMPANY_CLASS;
    searchVC.entityEditorClass = @"WCRoasterDetailsVC";
    searchVC.titleKey = NAME;
    searchVC.orderBy = NAME;
    searchVC.appendOnScroll  = YES;
    searchVC.queryPrefixKey = SEARCHABLE_WORDS;
    searchVC.tableViewDelegate = self;
    searchVC.title = @"Coffee Shops";
    searchVC.tabBarItem.title = @"Search";
    
    [searchVC.tabBarItem setImage: [[UIImage imageNamed:@"06-magnify"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    //[searchVC.tabBarItem setSelectedImage: [[UIImage imageNamed:@"people"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [tabbarCtrler addChildViewController:  [[UINavigationController alloc] initWithRootViewController:searchVC]];
    
    SSNearByVC *mapSearchVC = [[SSNearByVC alloc]init];
    mapSearchVC.objectType = COMPANY_CLASS;
    mapSearchVC.entityDetailsClass = @"WCRoasterDetailsVC";
    mapSearchVC.titleKey = NAME;
    mapSearchVC.limit = 20;
    mapSearchVC.deltaLongitude = 5.0;
    mapSearchVC.deltaLatitude  = 5.0;
    [mapSearchVC searchCurrentLocation];
    [tabbarCtrler addChildViewController:  [[UINavigationController alloc] initWithRootViewController:mapSearchVC]];
    
    SSProfileVC *profiles = [[SSProfileVC alloc]init];
    
    profiles.title = @"People";
    
    [profiles.tabBarItem setImage: [[UIImage imageNamed:@"112-group"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [profiles.tabBarItem setSelectedImage: [[UIImage imageNamed:@"112-group"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    //[tabbarCtrler addChildViewController: [[UINavigationController alloc]initWithRootViewController:profiles]];
    [tabbarCtrler addChildViewController:[[UINavigationController alloc] initWithRootViewController:[[SSFollowVC alloc]init]]];
    
    SSCommonSetupVC *settingsTab = [[SSCommonSetupVC alloc]init];
    
    [settingsTab.tabBarItem setImage: [[UIImage imageNamed:@"20-gear2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    settingsTab.editable = YES;
    [tabbarCtrler addChildViewController: [[UINavigationController alloc]initWithRootViewController:settingsTab]];
   
    
    SSConfigManager *configMgr = [SSConfigManager getConfigMgr];
    [configMgr getConfigurationWithBlock:^(id config) {
        if (config == nil || [config count] == 0)
        {
            [configMgr setValue:@"SSMyProfileVC" ofType:@"viewController" at:8 isSecret:NO for:@"Profile" ofGroup:@"0.Profile"];
            [configMgr setValue:@"" ofType:@"text" at:1 isSecret:NO for:@"End User Terms" ofGroup:@"1.About"];
            [configMgr setValue:@"" ofType:@"text" at:2 isSecret:NO for:@"Quick Start" ofGroup:@"1.About"];
            [configMgr setValue:@"" ofType:@"text" at:3 isSecret:NO for:@"About" ofGroup:@"1.About"];
            [configMgr save];
        }
    }];
    
    CGRect frame = CGRectMake(0, 0, 400, 148);
    UIView *viewa = [[UIView alloc] initWithFrame:frame];
    UIImage *tabBarBackgroundImage = [UIImage imageNamed:@"tabbarbg.png"];
    UIColor *color = [[UIColor alloc] initWithPatternImage:tabBarBackgroundImage];
    
    [viewa setBackgroundColor:color];
    
    float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
    
    if(iOSVersion <= 4.3)
    {
        [[tabbarCtrler tabBar] insertSubview:viewa atIndex:0];
    }
    else
    {
        [[tabbarCtrler tabBar] insertSubview:viewa atIndex:1];
    }
    
    
    return tabbarCtrler;
}


- (CGFloat) tableViewVC:(SSTableViewVC *)tableViewVC heightForRow:(NSInteger)row
{
    return 74;
}

- (UITableViewCell *) tableViewVC:(SSTableViewVC *)tableViewVC cellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    WCRoasterCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"WCRoasterCellId"];
    if (cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"WCRoasterCell" owner:self options:nil];
        cell = (WCRoasterCell *) [bundle objectAtIndex:0];
        
    }
    [cell configCell:[tableViewVC.objects objectAtIndex:indexPath.row]];
    return cell;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.isPublic = YES;
         
        self.name = @"Mappuccino";
        
        NSDictionary *jobTitles = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Shop Owner", @"owner",
                                   @"Consumer", @"consumer",
                                   @"N/A", @"na",
                                   nil];
        
        NSDictionary *group = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"Family Medicine", @"Family Medicine",
                    
                               nil];
        
        NSDictionary *shopTypes =
        @{
          @"1": @"Coffee",
          @"2": @"Restaurant",
          @"3": @"Hotel",
          @"4": @"Handyman",
          };

        [lovs setObject:shopTypes forKey:CATEGORY];
        
        [lovs setObject:group forKey:GROUPS];
        [lovs setObject:jobTitles forKey:JOB_TITLE];
    }
    return self;
}

- (void) updateHighlightItem:(id) item inView:(SSSpotlightView *) view
{
    if ([view.entityType isEqualToString:@"org_sixstreams_Company"])
    {
        
        [self addView:item inView:view withAttr:NAME at:1];
        [self addView:item inView:view withAttr:item[ADDRESS][STREET_ADDRESS] at:2];
        [self addView:item inView:view withAttr:PHONE at:3];
        [self addView:item inView:view withAttr:WEB_SITE at:4];
        [self addView:item inView:view withAttr:METRO at:5];
        
        SSImageView *recruitor = [[SSImageView alloc]initWithFrame:CGRectMake(view.frame.size.width - 30, 86, 24, 24)];
        recruitor.cornerRadius = 12;
        recruitor.image = [UIImage imageNamed:@"people.png"];
        recruitor.defaultImg = recruitor.image;
        recruitor.url = [[item objectForKey:USER_INFO] objectForKey:REF_ID_NAME];
        [view addSubview:recruitor];
    }
   
}

- (UIViewController *) entityVCFor :(NSString *) type
{
    if ([type isEqualToString:@"org_sixstreams_Company"]) {
        WCRoasterDetailsVC *childVC = [[WCRoasterDetailsVC alloc] init];
        
        //childVC.item2Edit = selectedObject;
        //childVC.itemType = self.objectType;
        return childVC;
        
    }
    return [super entityVCFor:type];
}

- (void) customizeAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar-background.png"] forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar-background.png"]];
}

- (NSString*) highlightTitle: (id) item forCategory: (NSInteger) currentPage
{
    return [self value: item forKey:NAME];
}

- (NSString*) highlightSubtitle: (id) item forCategory: (NSInteger) currentPage
{
    return  [self value:item forKey:item[ADDRESS][STREET_ADDRESS]];
}
@end
