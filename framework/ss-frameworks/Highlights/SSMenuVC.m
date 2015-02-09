//
//  SSMenuVC.m
//  SixStreams
//
//  Created by Anping Wang on 7/19/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSMenuVC.h"
#import "SSImageView.h"
#import "SSProfileVC.h"
#import "SSCommonVC.h"
#import "SSApp.h"
#import "SSEntityEditorVC.h"

@interface SSMenuVC ()
{
    __weak IBOutlet UILabel *profileName;
    __weak IBOutlet SSImageView *profileIcon;
    CGPoint startPoint;
}

@end

@implementation SSMenuVC

- (IBAction)showProfile:(id)sender
{
    SSEntityEditorVC *barItem = [[SSApp instance] entityVCFor : PROFILE_CLASS];
    barItem.readonly = YES;
    barItem.item2Edit = [SSProfileVC profile];
    [self.delegate menuVC:self didSelect:barItem];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshUI];
}
- (void) refreshUI
{
    self.objects = [NSMutableArray  array];
    int i=0;
    for (UIViewController *item in self.menuItems)
    {
        self.objects[i++] = @{@"name":item.title, @"item":item, @"desc":@"Grouping is fun"};
    }
    
    self.titleKey = @"name";
    
    id profile = [SSProfileVC profile];
    if (profile[PICTURE_URL])
    {
        profileIcon.isUrl = YES;
        profileIcon.url = profile[PICTURE_URL];
    }else
    {
        profileIcon.isUrl = NO;
        profileIcon.url = [SSProfileVC profileId];
    }
    
    
    profileIcon.cornerRadius = profileIcon.frame.size.height / 2;
    profileIcon.defaultImg = [UIImage imageNamed:@"person"];
    
    NSString *firstName = [profile objectForKey:FIRST_NAME];
    NSString *lastName = [profile objectForKey:LAST_NAME];
    firstName = firstName ? firstName : @"";
    lastName = lastName ? lastName : @"";
    profileName.text  = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [super refreshUI];
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    cellMargin = 42;
    iconMargin = 0;
    self.menuItems = [NSMutableArray array];
}

- (void) onSelect:(id) object
{
    UIViewController *barItem = object[@"item"];
    [self.delegate menuVC:self didSelect:barItem];
}

- (UIImageView *) imageForCell:(UITableViewCell *) cell row:(int) row// col:(int) col
{
    id item = [self.objects objectAtIndex:row];
    SSImageView *imageView = [[SSImageView alloc]initWithFrame:CGRectMake(20,1,24,24)];
    imageView.cornerRadius = 2;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIViewController *barItem = item[@"item"];
    imageView.image = barItem.tabBarItem.image;
    return imageView;
}


@end
