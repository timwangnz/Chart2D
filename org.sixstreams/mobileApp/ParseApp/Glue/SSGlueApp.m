//
//  SSGlueApp.m
//  Medistory
//
//  Created by Anping Wang on 11/12/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//
#import <Parse/Parse.h>

#import "SSGlueApp.h"
#import "SixStreams.h"
#import "SSGlueSettingsVC.h"
#import "SSGluedVC.h"
#import "SSGlueProfileVC.h"

#import "SSEventVC.h"
#import "SSProfileEditorVC.h"
#import "SSInviteVC.h"
#import "SSGroupVC.h"
#import "SSFilter.h"
#import "SSFriendVC.h"
#import "SSSecurityVC.h"

#import "SSImagesVC.h"
#import "SSProfileVC.h"
#import "SSConfigManager.h"
#import "SSActivityVC.h"

#import "SSSpotlightView.h"
#import "SSGroupVC.h"
#import "SSMenuVC.h"
#import "SSMeetupEditorVC.h"
#import "SSSearchVC.h"
#import "SSDeckViewVC.h"
#import "SSSlideOpenVC.h"
#import "SSMembershipVC.h"
#import "SSValueLabel.h"
#import "SSMyGroupsVC.h"
#import "SSCalendarConnector.h"
#import "SSDeviceTrackerVC.h"
#import "SSNearByVC.h"

@interface SSGlueApp ()<SSDeckViewVCDelegate>
{
    SSDeckViewVC *deckViewVC;
    SSGlueSettingsVC *settingsTab;
    SSProfileVC *profiles;
    SSInviteVC *invites;
    SSMembershipVC *myGroups;
    SSGroupVC *groups;
    UINavigationController *navCtrl;
    
    SSMenuVC *menuVC;
    SSSlideOpenVC *testVC;
}
@end


@implementation SSGlueApp

- (NSString *) appId
{
    return @"PSMk7ulKz7MMyFoDqQfR8DLQLc10CSnequbpPolk";//@"GZXD8slt1c887LCdRfNmNfdSTzxGMO7puVlWQcWP";
}

- (NSString *) appKey
{
    return @"YA35JDlm7cYz5m7aGUe4lA3Au49uSx1rxyh3768H";//@"NqjkoBhBWGhFRpgw7oWLrCPCrsSKIbdtVBZ0m3ek";
}

- (UIView *) backgroundView
{
    UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pageDetailEvent_TopNav"]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    return background;
}

- (BOOL) showPastEvents
{
    return YES;
}

- (BOOL) invitationOnly
{
    return NO;
}

- (UIViewController *) entityVCFor :(NSString *) type
{
    if ([type isEqualToString:@"org_sixstreams_user_Profile"] || [type isEqualToString:PROFILE_CLASS]) {
        return [[SSGlueProfileVC alloc]init];
    }
    if ([type isEqualToString:@"org_sixstreams_meetup_MeetUp"] || [type isEqualToString:MEETING_CLASS]) {
        return [[SSMeetupEditorVC alloc]init];
    }

    return [super entityVCFor:type];
}

-(UIViewController *) createRootVC
{
    SSDeviceTrackerVC *tracker = [[SSDeviceTrackerVC alloc]init];
    tracker.title = @"Take a picture";
    /*
    SSNearByVC *nearbyVC = [[SSNearByVC alloc]init];
    nearbyVC.showDeviceLoc = YES;
    nearbyVC.searchAllowed = NO;
    nearbyVC.trackDevice = YES;
    nearbyVC.deltaLatitude = 0.2;
    nearbyVC.deltaLongitude = 0.2;
    nearbyVC.delegate = self;
    
    nearbyVC.title = @"Lazy Eye";*/
    return  tracker;//[[UINavigationController alloc]initWithRootViewController:tracker];
}


-(UIViewController *) _createRootVC
{

    deckViewVC =[[SSDeckViewVC alloc]init];
    deckViewVC.objectType = MEETING_CLASS;
    deckViewVC.limit = 20;
    deckViewVC.tabBarItem.image = [UIImage imageNamed:@"pageMenuNav_GlueIcon"];
    deckViewVC.delegate = self;
    
    invites = [[SSInviteVC alloc]init];
    [invites.predicates addObject:[SSFilter on:INVITEE_ID
                                            op:EQ
                                         value:[SSProfileVC profileId]]];
    
    invites.title = @"My Events";
    invites.tabBarItem.image =[UIImage imageNamed:@"pageMenuNav_MyeventsIcon"];
    
    myGroups = [[SSMembershipVC alloc]init];
    myGroups.title = @"Groups";
    myGroups.limit = 20;
    myGroups.orderBy = UPDATED_AT;
    myGroups.appendOnScroll = YES;
    myGroups.ascending = NO;
    myGroups.tabBarItem.image = [UIImage imageNamed:@"pageMenuNav_GroupsIcon"];
    
    groups = [[SSGroupVC alloc]init];
    groups.title = @"Public Groups";
    groups.limit = 20;
    groups.orderBy = UPDATED_AT;
    groups.appendOnScroll = YES;
    groups.ascending = NO;
    groups.tabBarItem.image = [UIImage imageNamed:@"pageMenuNav_GroupsIcon"];
    
    profiles = [[SSProfileVC alloc] init];
    profiles.title = @"People";
    profiles.tabBarItem.image = [UIImage imageNamed:@"pageMenuNav_PeopleIcon"];
    
    settingsTab = [[SSGlueSettingsVC alloc]init];
    
    settingsTab.title = @"Settings";
    settingsTab.tabBarItem.image = [UIImage imageNamed:@"pageMenuNav_SettingIcon"];
    
    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:USER];
    [[PFInstallation currentInstallation] addUniqueObject:@"glue-global" forKey:@"channels"];
    [[PFInstallation currentInstallation] saveEventually];
    
    menuVC = [[SSMenuVC alloc]init];
    [menuVC.menuItems addObject: deckViewVC];
    [menuVC.menuItems addObject: myGroups];
    
    [menuVC.menuItems addObject: invites];
    
    [menuVC.menuItems addObject: settingsTab];
  
    deckViewVC.menuViewControl = menuVC;
   
    navCtrl = [[UINavigationController alloc]initWithRootViewController:deckViewVC];
    return navCtrl;
}


- (NSString *) getAppIconName
{
    return @"pageLoading_Icon";    
}

- (NSString *) textForVote:(BOOL) vote
{
    return vote ? @"Attend" : @"Next";
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.displayName = @"Gloofy";
         self.isPublic = YES;
        NSDictionary *eventTypes = @{
                                     @"0":@"Lunch",
                                     @"1":@"Study",
                                     @"2": @"Wedding",
                                     @"3": @"Birthday",
                                     @"4": @"Movie",
                                     @"5": @"Reunion",
                                     @"6":@"Trip"
                                     };
        [lovs setObject:eventTypes forKey:EVENT_TYPE];
    }
    return self;
}



- (void) addView:(id) item inView:(UIView *) view withAttr:(NSString *) attrName at: (NSInteger) order
{
    SSValueLabel *label = (SSValueLabel*) [view viewWithTag:order];
    if (!label)
    {
        label = [[SSValueLabel alloc]initWithFrame:CGRectMake(4, (order - 1) * 20 + 10, view.frame.size.width - 5, 20)];
        label.font = [UIFont systemFontOfSize:order == 1 ? 17 : 12];
        label.textColor = [UIColor darkGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.attrName = attrName;
        label.tag = order;
        [view addSubview:label];
    }
    
    label.text = [self value:item forKey:attrName];
    
    
}

- (void) updateHighlightItem:(id) item ofType:(NSString *) itemType inView:(UIView *) view
{
    if ([itemType isEqualToString:MEETING_CLASS])
    {
        static int imgSize = 48;
        
        SSImageView *iconImg = [[SSImageView alloc]initWithFrame:CGRectMake((view.frame.size.width - imgSize)/2, 10, imgSize, imgSize)];
        
        iconImg.cornerRadius = imgSize/2;
        iconImg.url = item[ORGANIZER][REF_ID_NAME];
        iconImg.defaultImg = [UIImage imageNamed:@"people"];
        [view addSubview:iconImg];
        
        [self addView:item inView:view withAttr:TITLE at:1];
        [self addView:item inView:view withAttr:USER at:2];
        view.backgroundColor = [UIColor colorWithRed:0.9 green:0.90 blue:0.9 alpha:0.5];
    }
    else
    {
        [super updateHighlightItem:item ofType:itemType inView:view];
    }
}

- (UIImage *) defaultImage:(id) item ofType:(NSString *) type
{
    if([type isEqualToString:USER_TYPE])
    {
        NSString *type = [item objectForKey:USER_TYPE];
        if ([type isEqualToString:@"8"])
        {
            return [UIImage imageNamed:@"star01"];
        }
        else if ([type isEqualToString:@"6"])
        {
            return [UIImage imageNamed:@"triangle"];
        }
        else if ([type isEqualToString:@"7"])
        {
            return [UIImage imageNamed:@"star02"];
        }
        else
        {
            return [UIImage imageNamed:@"circle"];
        }
    }else if([type isEqualToString:MEETING_CLASS])
    {
        return [UIImage imageNamed:@"main_03.png"];
    }
    return nil;
}

- (NSString *) displayName:(NSString *) attrName ofType:(NSString *) objectType
{
    if ([attrName isEqualToString:@"jobTitles"])
    {
        return @"Fields";
    }
    if ([attrName isEqualToString:@"ss_groups"])
    {
        return @"Classification";
    }
    
    if ([attrName isEqualToString:@"jobTitle"])
    {
        return @"Field";
    }
    return [attrName fromCamelCase];
}

- (NSString *) format:(id)attrValue forAttr:(NSString *)attrName ofType:(NSString *)objectType
{
    
    if ([attrName isEqualToString:DATE_FROM])
    {
        return [((NSDate *)attrValue) toDateTimeString];
    }
    return [super format:attrValue forAttr:attrValue ofType:objectType];
}

@end
