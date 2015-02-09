//
//  OPCSSSetupViewController.m
//  FileSync
//
//  Created by Anping Wang on 9/21/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSCommonSetupVC.h"
#import "SSSettingAttributeEditorVC.h"
#import "SSConfigManager.h"
#import "SSSecurityVC.h"

@interface SSCommonSetupVC ()<SSSigninDelegate>
{
    SSSecurityVC *loginVC;
}

@property (nonatomic) id selectedValue;
@property (nonatomic) id selectedSection;
@end

@implementation SSCommonSetupVC

+ (UINavigationController *) initSetupVC
{
    SSCommonSetupVC *setupViewController = [[SSCommonSetupVC alloc] init];
    UINavigationController *setupNavigationController = [[UINavigationController alloc] initWithRootViewController:setupViewController];
    return setupNavigationController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(SETTINGS, SETTINGS);
        self.tabBarItem.image = [UIImage imageNamed:@"19-gear"];
    }
    return self;
}

- (IBAction)unattachDevice:(id)sender
{
    if (_delegate)
    {
        [_delegate onClearConfiguration];
    }
}

- (void) didLogin : (id) user
{
    [loginVC.view removeFromSuperview];
    [self reloadData];
}

- (void) didSignup : (id) user
{
    [loginVC.view removeFromSuperview];
    [self reloadData];
}
- (void) didLogoff
{
    //does nothing here
}

- (IBAction)closeWindow :(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) reloadData
{
    [[SSConfigManager getConfigMgr] getConfigurationWithBlock:^(id data) {
        self.entity = [[NSMutableDictionary alloc]initWithDictionary:data];
        orderedSections = [[self.entity allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        [attrTableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL loggedIn = [SSSecurityVC checkLogin:^(id user) {
         //
    }];
    if (loggedIn)
    {
        [super viewWillAppear:animated];
        if(loginVC)
        {
            [loginVC.view removeFromSuperview];
        }
        [self reloadData];
    }
    else{
        loginVC = [SSSecurityVC instance];
        loginVC.signinDelegate = self;
        [self.view addSubview:loginVC.view];
        [self.view bringSubviewToFront:loginVC.view];
    }
}

- (void) valueDidChange : (id) sender
{
    SSConfigManager *configMgr = [SSConfigManager getConfigMgr];
    [configMgr setValue:sender for:[self.selectedValue objectForKey:NAME] ofGroup:self.selectedSection];
    [configMgr save];
    [self.navigationController popViewControllerAnimated:YES];
    self.entity = [[NSMutableDictionary alloc]initWithDictionary:[configMgr getConfiguration]];
    [attrTableView reloadData];
}


@end