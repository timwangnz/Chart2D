//
//  SSGlueProfileVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/13/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSGlueProfileVC.h"
#import "iCarousel.h"
#import "SSEventView.h"
#import "SSInviteEditorVC.h"
#import "SSConnection.h"
#import "SSInviteVC.h"
#import "SSFilter.h"
#import "SSRoundTextView.h"
#import "SSGlueCatVC.h"
#import "SSApp.h"
#import "SSMembershipVC.h"
#import "SSSearchVC.h"

@interface SSGlueProfileVC ()<SSTableViewVCDelegate>
{
    IBOutlet UIView *vProjects;
    IBOutlet iCarousel *myGlued;
    IBOutlet UIView *pastEventsView;
    IBOutlet SSRoundTextView *tvProjects;
    NSMutableArray *eventViews;
    NSArray *invites;
    float iconSize;
}

@end

@implementation SSGlueProfileVC

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    iconSize = myGlued.frame.size.height * 0.9;
    [self linkEditFields];
    [layoutTable reloadData];
}

- (NSString *) tableViewVC:(id) tableViewVC cellText: (id)rowItem atCol:(int) col
{
    return rowItem[GROUP_NAME];
}

- (UIImageView *) tableViewVC:(id) tableViewVC cellIcon:(id)rowItem atCol:(int)col
{
    SSImageView *ssImageView = [[SSImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    ssImageView.defaultImg = [UIImage imageNamed:@"112-group.png"];
    ssImageView.image = [UIImage imageNamed:@"112-group.png"];
    ssImageView.url = rowItem[GROUP_ID];
    ssImageView.cornerRadius = 4;
    return ssImageView;
}

- (void) viewGroups:(id) sender
{
    SSSearchVC *groups = [[SSSearchVC alloc]init];
    groups.titleKey = GROUP_NAME;
    groups.objectType = MEMBERSHIP_CLASS;
    groups.iconKey = GROUP_ID;
    groups.editable = NO;
    groups.addable = NO;
    groups.tableViewDelegate = self;
    groups.title = @"My Groups";
    [groups.predicates addObject:[SSFilter on: USER_ID op:EQ value: self.item2Edit[REF_ID_NAME]]];
    [groups refreshOnSuccess:^(id data) {
        [self.navigationController pushViewController:groups animated:YES];
    } onFailure:^(NSError *error) {
        //show alert
    }];
}

#pragma iCarousel

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    for(UIView *eventView in eventViews)
    {
        [eventView removeFromSuperview];
    }
    
    eventViews = [NSMutableArray array];
    for (id item in invites)
    {
        SSEventView *eventView = [[SSEventView alloc]initWithEvent:item];
        
        eventView.frame = CGRectMake(0, 20, iconSize ,iconSize);
        eventView.imageOnly = YES;
        eventView.backgroundColor = [UIColor whiteColor];
        [eventView refreshUI];
        [eventViews addObject:eventView];
    }
    return [eventViews count];
}


- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    SSEventView *eventView =[eventViews objectAtIndex:index];
    id item = eventView.event;
    
    SSInviteEditorVC *meetVC = [[SSInviteEditorVC alloc]init];
   
    meetVC.readonly = YES;
    
    meetVC.title = [item objectForKey:TITLE];
    [meetVC updateEntity:item OfType:INVITE_CLASS];
    [meetVC updateData:^(id data) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @""
                                       style: UIBarButtonItemStylePlain
                                       target: nil action: nil];
        
        [self.navigationItem setBackBarButtonItem: backButton];
        [self.navigationController pushViewController:meetVC animated:YES];
    }];
    
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIView *label = nil;
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize , iconSize )];
        ((UIImageView *)view).image = [UIImage imageNamed:@"browser03_bg-school"];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        label = (UILabel *)[view viewWithTag:1];
    }
    
    UIView *childView = [eventViews objectAtIndex:index];
    CGRect rect = childView.frame;
    rect.origin.y = 0;
    
    childView.frame = view.frame;
    [childView removeFromSuperview];
    [label addSubview:childView];
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return 1.1;
    }
    return value;
}

@end
