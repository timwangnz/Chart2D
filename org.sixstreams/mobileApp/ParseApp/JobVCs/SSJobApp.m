//
//  SSJobApp.m
//  SixStreams
//
//  Created by Anping Wang on 3/29/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSJobApp.h"
#import "SSJSonUtil.h"
#import "SixStreams.h"
#import "SSResumeVC.h"
#import "SSJobEditorVC.h"
#import "SSCommonSetupVC.h"
#import "SSConfigManager.h"
#import "SSSearchVC.h"
#import "SSProfileVC.h"
#import "SSActivityVC.h"
#import "SSFollowVC.h"
#import "SSProfile4JobVC.h"
#import "SSHighlightsVC.h"
#import "SSCompanyVC.h"
#import "SSJobApplicationVC.h"
#import "SSValueLabel.h"
#import "SSSkillEditor.h"
#import "SSJobsLookups.h"
#import "SSContainerVC.h"
#import "SSJobLayoutVC.h"
#import "SSDeckViewVC.h"
#import "SSMenuVC.h"
#import "SSSurveyVC.h"
#import "SSMessagingVC.h"


@interface SSJobApp ()<SSTableViewVCDelegate>
{
    SSSearchVC *jobListVC;
    SSProfileVC *profiles;
    SSDeckViewVC *deckViewVC;
    SSMenuVC *menuVC;
    UINavigationController *navCtrl;
}
@end

@implementation SSJobApp

//
- (id) init
{
    self = [super init];
    if (self)
    {
        self.isPublic = NO;
        self.displayName = @"Job";
        lovs = [[[SSJobsLookups alloc]init] getLovs];
    }
    return self;
}

//customize activity stream UI
- (UIViewController *) createVCForActivity:(id) activity
{
    NSString *objectId = [[activity objectForKey:@"object"] objectForKey:REF_ID_NAME];
    id item = [[SSConnection connector] objectForKey:objectId ofType:JOB_CLASS];
    if (item)
    {
        SSJobEditorVC *jobEditor = [[SSJobEditorVC alloc]init];
        jobEditor.readonly = YES;// item != nil && ![[item objectForKey:AUTHOR] isEqualToString:[SSProfileVC profileId]];
        [jobEditor updateEntity:item OfType:JOB_CLASS];
        return jobEditor;
    }
    else
    {
        return nil;
    }
}

- (id) contextForActiviy:(id) activity onSubject:(NSString *) subject
{
    if ([subject isEqualToString:@"Job"])
    {
        return [self value:[activity objectForKey:CONTEXT] forKey:JOB_TITLE];
    }
    return [activity objectForKey:CONTEXT];
}

- (id) contextualObject:(id) item ofType:(NSString *) type
{
    if ([type isEqualToString:JOB_CLASS])
    {
        return @{NAME: [self value:item forKey:JOB_TITLE],
                 SUBTITLE : [self value:item forKey:INDUSTRY],
                 USER : [self value:item forKey:USER],
                 REF_ID_NAME: [item objectForKey:REF_ID_NAME]
                 };
    }
    if ([type isEqualToString:RESUME_CLASS])
    {
        return @{NAME: [item objectForKey:NAME],
                 SUBTITLE : [self value:item forKey:SUBTITLE],
                 REF_ID_NAME: [item objectForKey:REF_ID_NAME]
                 };
    }
    return [super contextualObject:item ofType:type ];
}


- (BOOL) enableSocialProfile
{
    return YES;
}

- (NSString *) editorClassFor:(NSString *) objectType
{
    if ([objectType isEqualToString:JOB_CLASS]) {
        return @"SSJobEditorVC";
    }
    if ([objectType isEqualToString:@"org_sixstreams_user_Profile"] || [objectType isEqualToString:PROFILE_CLASS]) {
        return @"SSProfile4JobVC";
    }
    return [super editorClassFor:objectType];
}

- (UIViewController *) createRootVC
{
    if ([self isIPad])
    {
        SSContainerVC *containerVC = [[SSContainerVC alloc]init];
        self.displayName = @"Job1";
        return containerVC;
    }
    
    SSActivityVC *activityVC = [[SSActivityVC alloc]init];
    activityVC.tabBarItem.image = [UIImage imageNamed:@"137-presentation"];
    
    SSCompanyVC *companySearchVC = [[SSCompanyVC alloc]initWithNibName:@"SSSearchVC" bundle:nil];
    
    companySearchVC.objectType = COMPANY_CLASS;
    companySearchVC.entityEditorClass = @"SSCompanyEditorVC";
    companySearchVC.titleKey = NAME;
    companySearchVC.iconKey = REF_ID_NAME;
    companySearchVC.subtitleKey = INDUSTRY;
    companySearchVC.orderBy = NAME;
    companySearchVC.defaultHeight = 54;
    companySearchVC.queryPrefixKey = SEARCHABLE_WORDS;
    companySearchVC.addable = YES;
    companySearchVC.title = @"Companies";
    companySearchVC.ascending = NO;
    companySearchVC.tabBarItem.image = [UIImage imageNamed:@"177-building"];
    companySearchVC.filterable = YES;
    
    jobListVC = [[SSSearchVC alloc]init];
    jobListVC.objectType = JOB_CLASS;
    jobListVC.entityEditorClass = @"SSJobEditorVC";
    jobListVC.titleKey = JOB_TITLE;
    jobListVC.subtitleKey = COMPANY;
    jobListVC.iconKey = REF_ID_NAME;
    jobListVC.defaultIconImgName = @"jobx2";
    jobListVC.orderBy = JOB_TITLE;
    jobListVC.queryPrefixKey = SEARCHABLE_WORDS;
    jobListVC.addable = YES;
    jobListVC.title = @"Jobs";
    jobListVC.defaultHeight = 64;
    jobListVC.orderBy = UPDATED_AT;
    jobListVC.ascending = NO;
    jobListVC.tabBarItem.image = [UIImage imageNamed:@"jobx2"];
    jobListVC.filterable = YES;
    
    profiles = [[SSProfileVC alloc]init];
    profiles.title = @"People";
    profiles.tabBarItem.image = [UIImage imageNamed:@"people"];
    
    
    SSCommonSetupVC *settingsTab = [[SSCommonSetupVC alloc]init];
    settingsTab.tabBarItem.image = [UIImage imageNamed:@"gear_inx2"];
    settingsTab.editable = YES;
    
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
    
    deckViewVC =[[SSDeckViewVC alloc]init];
    deckViewVC.objectType = JOB_CLASS;
    [deckViewVC.predicates addObject:[SSFilter on:PUBLISHED op:EQ value:[NSNumber numberWithBool:YES]]];
  
    deckViewVC.limit = 20;
    deckViewVC.tabBarItem.image = [UIImage imageNamed:@"job58"];
    
    
   // [deckViewVC.predicates addObject:[SSFilter on:DATE_FROM op:GREATER value:[NSDate date]]];
   // [deckViewVC.predicates addObject:[SSFilter on:GROUP op:CONTAINS value: @[@"public"]]];
  //  deckViewVC.delegate = self;

   // deckviewVC.tabBarItem.image = [UIImage imageNamed:@"02-redo"];
    
    SSSurveyVC *softSkillSurvey = [[SSSurveyVC alloc] init];
    softSkillSurvey.title = @"Skill Survey";
    softSkillSurvey.sectioned = YES;
    softSkillSurvey.items = [[SSApp instance] getLov:SOFT_SKILL ofType:JOB_CLASS];
    softSkillSurvey.tabBarItem.image = [UIImage imageNamed:@"12-eye"];
    
    menuVC = [[SSMenuVC alloc]init];
    [menuVC.menuItems addObject: deckViewVC];
    [menuVC.menuItems addObject: companySearchVC];
    [menuVC.menuItems addObject: jobListVC];
    [menuVC.menuItems addObject: profiles];
    [menuVC.menuItems addObject:softSkillSurvey];
    [menuVC.menuItems addObject: settingsTab];
    deckViewVC.menuViewControl = menuVC;
    
    navCtrl = [[UINavigationController alloc]initWithRootViewController:deckViewVC];
    
    return navCtrl;
}


- (void) add
{
    [deckViewVC.navigationController pushViewController: jobListVC animated:YES];
}

- (NSString *) appId
{
    return @"QGmVk5y0LjFvR4DD0eDNtM2AWnv68FXjYjsOSAQM";
}

- (NSString *) appKey
{
    return @"UhUviNgVuQxSQ860V66c3epnK8c94HOP4xBgmp5W";
}

- (NSString *) displayName:(NSString *) attrName ofType:(NSString *) objectType
{
    if ([attrName isEqualToString:JOB_TITLE])
    {
        return @"Title";
    }
    if ([attrName isEqualToString:GROUPS])
    {
        return @"Industry";
    }
    
    return [attrName fromCamelCase];
}

- (NSString*) highlightTitle: (id) item forCategory: (NSInteger) currentPage
{
    return [self value: item forKey:JOB_TITLE];
}

- (NSString*) highlightSubtitle: (id) item forCategory: (NSInteger) currentPage
{
    return  [self value:item forKey:COMPANY];
}

- (void) updateHighlightItem:(id) item ofType:(NSString *)itemType inView:(UIView *)view
{
    if ([itemType isEqualToString:JOB_CLASS])
    {
        [self addView:item inView:view withAttr:JOB_TITLE at:1];
        [self addView:item inView:view withAttr:COMPANY at:2];
        [self addView:item inView:view withAttr:INDUSTRY at:3];
        [self addView:item inView:view withAttr:METRO at:4];
        [self addView:item inView:view withAttr:PAY_RATE at:5];
        SSImageView *recruitor = [[SSImageView alloc]initWithFrame:CGRectMake(view.frame.size.width - 30, 66, 24, 24)];
        recruitor.cornerRadius = 12;
        recruitor.image = [UIImage imageNamed:@"people.png"];
        recruitor.defaultImg = recruitor.image;
        recruitor.url = [[item objectForKey:USER_INFO] objectForKey:REF_ID_NAME];
        [view addSubview:recruitor];
        view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8];
    }
    else{
        [super updateHighlightItem:item ofType:itemType inView:view];
    }
}

- (UIViewController *) entityVCFor :(NSString *) type
{
    if ([type isEqualToString:HIGHLIGHTS])
    {
        return [[SSJobEditorVC alloc]init];
    }
    if ([type isEqualToString:SEARCH])
    {
        jobListVC = [[SSSearchVC alloc]init];
        jobListVC.tableViewDelegate = self;
        
        jobListVC.objectType = JOB_CLASS;
        jobListVC.entityEditorClass = @"SSJobEditorVC";
        jobListVC.titleKey = JOB_TITLE;
        jobListVC.orderBy = JOB_TITLE;
        jobListVC.queryPrefixKey = SEARCHABLE_WORDS;
        
        jobListVC.addable = YES;
        jobListVC.title = @"Jobs";
        jobListVC.orderBy = UPDATED_AT;
        jobListVC.ascending = NO;
        jobListVC.tabBarItem.image = [UIImage imageNamed:@"jobx2"];
        return jobListVC;
    }
    if ([type isEqualToString:@"org.sixstreams.job.Skill"])
    {
        SSSkillEditor *skillEditor = [[SSSkillEditor alloc]init];
        return skillEditor;
    }
    
    if ([type isEqualToString:RESUME_CLASS])
    {
        SSResumeVC *resumeVC = [[SSResumeVC alloc]init];
        resumeVC.readonly = NO;
        return resumeVC;
    }
    
    if ([type isEqualToString:RESUME_CLASS])
    {
        SSResumeVC *resumeVC = [[SSResumeVC alloc]init];
        resumeVC.readonly = NO;
        return resumeVC;
    }
    
    if ([type isEqualToString:JOB_APPLICATION_CLASS])
    {
        SSJobApplicationVC *jobEditor = [[SSJobApplicationVC alloc]init];
        jobEditor.readonly = NO;
        return jobEditor;
    }
    else if ([type isEqualToString:@"org_sixstreams_jobs_Job"] || [type isEqualToString:JOB_CLASS])
    {
        return [[SSJobEditorVC alloc]init];
    }
    
    if ([type isEqualToString:@"org_sixstreams_user_Profile"] || [type isEqualToString:PROFILE_CLASS]) {
        return [[SSProfile4JobVC alloc]initWithNibName:@"SSProfileEditorVC" bundle:nil];
    }
    
    return [super entityVCFor:type];
}


- (UIImage *) defaultImage:(id) item ofType:(NSString *) type
{
    
    if([type isEqualToString:USER_TYPE])
    {
        NSString *type = [item objectForKey:USER_TYPE];
        if ([type isEqualToString:@"1"])
        {
            return [UIImage imageNamed:@"triangle"];
        }
        else
        {
            return [UIImage imageNamed:@"circle"];
        }
    }
    return [UIImage imageNamed:@"company"];
}

- (SSLayoutVC *) getLayoutVC
{
    return [[SSJobLayoutVC alloc]init];
}

//setup application background
- (UIView *) backgroundView
{
    UIImageView *background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"jobs-bg.jpg"]];
    background.contentMode = UIViewContentModeScaleAspectFill;
    return background;
}

//flag that allows resume for people
- (BOOL) enableResume
{
    return YES;
}

- (void) syncMetro
{
    NSMutableArray *objects = [NSMutableArray array];
    NSDictionary *lookups =[self getLov:METRO_AREA ofType:JOB_CLASS];
    for(NSString *key in lookups)
    {
        NSArray *location = [key componentsSeparatedByString:@","];
        NSString * value = [lookups objectForKey:key];
        NSArray *keywords = [value componentsSeparatedByString:@","];
        [objects addObject:@{@"latitude": [NSNumber numberWithFloat:[[location objectAtIndex:0] floatValue]],
                             @"longitude": [NSNumber numberWithFloat:[[location objectAtIndex:1] floatValue]],
                             @"value": [lookups objectForKey:key],
                             @"searchableWords":keywords
                             }];
    }
    int i = 1;
    NSDictionary *metro =[[SSApp instance] getLov:METRO_AREA ofType:JOB_CLASS];
    for (NSString *key in [metro allKeys]) {
        NSArray *comps = [key componentsSeparatedByString:@","];
        DebugLog(@"@\"%d\":@{@\"latitude\":@\"%@\",@\"longitude\":@\"%@\",@\"name\":@\"%@\"},", i++, comps[0], comps[1], metro[key]);
    }
    
    SSConnection *conn = [SSConnection connector];
    [conn uploadObjects:objects ofType:@"org.sixstreams.jobs.lookups.Metro"];
}
//only used to upload job to the server
- (void) syncJobTypes
{
    NSMutableArray *objects = [NSMutableArray array];
    NSDictionary *lookups =[self getLov:JOB_TITLE ofType:JOB_CLASS];
    for(NSString *key in lookups)
    {
        NSString * value = [lookups objectForKey:key];
        NSArray *keywords = [[value componentsSeparatedByString:@","] toKeywordList];
        [objects addObject:@{@"code": key,
                             @"value": [lookups objectForKey:key],
                             @"searchableWords":keywords
                             }];
    }
    SSConnection *conn = [SSConnection connector];
    [conn uploadObjects:objects ofType:@"org.sixstreams.jobs.lookups.JobTitle"];
}

- (void) customizeAppearance
{
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar_background.png"] forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bar_background.png"]];
}

@end
