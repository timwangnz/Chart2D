//
//  SSMembershipVC.m
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSMembershipVC.h"
#import "SSConnection.h"
#import "SSImageView.h"
#import "SSFilter.h"
#import "SSProfileVC.h"
#import "SSApp.h"
#import "SSEntityEditorVC.h"
#import "SSGroupEditorVC.h"
#import "SSGroupVC.h"

@interface SSMembershipVC ()
{
    IBOutlet UIView *menuView;
}

@end

@implementation SSMembershipVC

+ (void) getMyGroupsOnSuccess: (SuccessCallback) callback
{
    SSMembershipVC *ssMembership = [[SSMembershipVC alloc]init];
    [ssMembership.predicates addObject:[SSFilter on:USER_ID op:EQ value:[SSProfileVC profileId]]];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"public"];
    [ssMembership refreshAndWait:^(id data) {
        for (id object in ssMembership.objects) {
            [array addObject:object[GROUP_ID]];
        }
        callback(array);
    } onFailure:^(NSError *error) {
        //
    }];
}

+ (void) groupsFor:(id) userId onSuccess: (SuccessCallback) callback
{
    SSMembershipVC *ssMembership = [[SSMembershipVC alloc]init];
    [ssMembership.predicates addObject:[SSFilter on:USER_ID op:EQ value:userId]];
    [ssMembership refreshOnSuccess:^(id data) {
        NSMutableArray *array = [NSMutableArray array];
        for (id object in ssMembership.objects) {
            NSDictionary *group = @{@"id": object[GROUP_ID], @"name":object[GROUP_NAME], REF_ID_NAME:object[GROUP_ID]};
            [array addObject:[NSMutableDictionary dictionaryWithDictionary:group]];
        }
        callback(array);
    } onFailure:^(NSError *error) {
        //
    }];
}

+ (void) user:(id)profileId isMemberOfGroup:(id) groupId onSuccess: (SuccessCallback) callback
{
    SSMembershipVC *ssMembership = [[SSMembershipVC alloc]init];
    [ssMembership.predicates addObject:[SSFilter on:GROUP_ID op:EQ value:groupId]];
    [ssMembership.predicates addObject:[SSFilter on:USER_ID op:EQ value:profileId]];
    [ssMembership refreshOnSuccess:^(id data) {
        callback(ssMembership.objects);
    } onFailure:^(NSError *error) {
        //
    }];
}

+ (void) user:(id)profileId leave:(id) groupId onSuccess: (SuccessCallback) callback
{
    SSMembershipVC *ssMembership = [[SSMembershipVC alloc]init];
    [ssMembership.predicates addObject:[SSFilter on:GROUP_ID op:EQ value:groupId]];
    [ssMembership.predicates addObject:[SSFilter on:USER_ID op:EQ value:profileId]];
    [ssMembership deleteObjects:MEMBERSHIP_CLASS onSuccess:^(id data) {
        if(callback)
        {
            callback(data);
        }
    } onFailure:^(NSError *error) {
        //
    }];
    
}

+ (void) user: (id)user
         join: (id)group
    onSuccess: (SuccessCallback) callback
{
    NSMutableDictionary *membership = [NSMutableDictionary dictionary];
    [membership setValue:[user objectForKey:USERNAME] forKey:USERNAME];
    [membership setValue:[user objectForKey:FIRST_NAME] forKey:FIRST_NAME];
    [membership setValue:[user objectForKey:LAST_NAME] forKey:LAST_NAME];
    [membership setValue:[group objectForKey:NAME] forKey:GROUP_NAME];
    [membership setValue:[group objectForKey:REF_ID_NAME] forKey:GROUP_ID];
    [membership setValue:[user objectForKey:REF_ID_NAME] forKey:USER_ID];
    if([user objectForKey:PICTURE_URL])
    {
        [membership setValue:[user objectForKey:PICTURE_URL] forKey:PICTURE_URL];
    }
    SSConnection *conn = [SSConnection connector];
    [conn createObject:membership ofType:MEMBERSHIP_CLASS
             onSuccess:^(NSDictionary *data) {
                 if(callback)
                 {
                     callback(data);
                 }
             } onFailure:^(NSError *error) {
    
             }];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger num = [self.objects count];
    if (num % 2)
        return [self.objects count]/2 + 1;
    else
        return [self.objects count]/2;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    cellMargin = 5;
    [self refreshOnSuccess:^(id data) {
        [self refreshUI];
    } onFailure:^(NSError *error) {
        //
    }];
}

#define CELL @"cell"

- (UIImageView *) imageForCell:(UITableViewCell *) cell row:(NSUInteger) row col:(NSUInteger) col
{
    id item  = [self.objects objectAtIndex:row*2+col];
    SSImageView *imageView = [[SSImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.cornerRadius = 0;
    imageView.image = [UIImage imageNamed:@"groupDefault"];
    imageView.owner = [item objectForKey:AUTHOR];
    imageView.url = [item objectForKey:GROUP_ID];
    return imageView;
}

- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(NSUInteger) row
{
    int height = self.defaultHeight;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,0,cell.frame.size.width, height)];
    
    view.backgroundColor = [UIColor clearColor];
    UIView *view1 = [self tableView: tableView cell:cell row:row col:0];
    UIView *view2 = [self tableView: tableView cell:cell row:row col:1];
    
    [view addSubview:view1];
    if (view2)
    {
        view2.frame = CGRectMake(height + cellMargin, cellMargin, height - 2 * cellMargin,height - 2 * cellMargin);
        [view addSubview:view2];
    }
    return view;
}

- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(NSUInteger) row col:(NSUInteger) col
{
    int height = self.defaultHeight;
   
    if(row * 2 +  col > [self.objects count] - 1)
    {
        return nil;
    }
    
    UIImageView *imageView = [self imageForCell:cell row:row col:col];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0,height - 2 * cellMargin, height - 2 * cellMargin)];
    
    imageView.frame = CGRectMake(0, 0, height - 2 * cellMargin, height - 2 * cellMargin);
    
    [view addSubview:imageView];
    
    UIButton *textView = [[UIButton alloc]initWithFrame:imageView.frame];
    
    textView.tag = row * 2 +  col;
    
    id item = self.objects[textView.tag];
    
    [textView addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
    textView.alpha = 0.5;
    textView.backgroundColor = [UIColor blackColor];
    
    imageView.frame = view.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
   
    [view addSubview:textView];
    [view bringSubviewToFront:textView];
    
    NSString *cellText = item[GROUP_NAME];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, height/2 - 20, textView.frame.size.width- 20, 48)];
    label.text  = cellText;
    label.center = view.center;
    label.numberOfLines = 2;
    
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    view.frame = CGRectMake(cellMargin, cellMargin, height - 2 * cellMargin, height - 2 *cellMargin);
    return view;
}

- (IBAction) createGroup:(id)sender
{
    [super create];
    [self dissmissView:menuView];
}

- (void) editObject:(id) item
{
    SSEntityEditorVC *entityEditor = [[SSGroupEditorVC alloc]init];
    if (item)
    {
        entityEditor.itemType = GROUP_CLASS;
        [self getObject:item[GROUP_ID] objectType:GROUP_CLASS OnSuccess:^(id data) {
            [entityEditor updateEntity:data OfType: GROUP_CLASS];
            entityEditor.readonly = YES;
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                           initWithTitle: @""
                                           style: UIBarButtonItemStylePlain
                                           target: nil action: nil];
            
            [self.navigationItem setBackBarButtonItem: backButton];
            [self.navigationController pushViewController:entityEditor animated:YES];
        } onFailure:^(NSError *error) {
            //
        }];
    }
    else
    {
        entityEditor.itemType = GROUP_CLASS;
        entityEditor.readonly = NO;
        [self.navigationController pushViewController:entityEditor animated:YES];
    }
    entityEditor.title = @"Group";
}



- (void) didSelect:(UIButton *) sender
{
    id item = self.objects[sender.tag];
    [self onSelect:item];
    [dataView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //do nothing
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        int height = self.defaultHeight == 0 ? tableView.rowHeight : self.defaultHeight;
        cell.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
    cell.textLabel.text = @"";
    UIView *cellFrame = [self tableView:tableView cell:cell row:indexPath.row];
    [cell.contentView addSubview: cellFrame];
    return cell;
}

- (IBAction) showSearch:(id) sender
{
   SSGroupVC * groups = [[SSGroupVC alloc]init];
    groups.title = @"Public Groups";
    groups.limit = 20;
    groups.orderBy = UPDATED_AT;
    groups.appendOnScroll = YES;
    groups.ascending = NO;
    groups.tabBarItem.image = [UIImage imageNamed:@"pageMenuNav_GroupsIcon"];
    [groups refreshOnSuccess:^(id data) {
        [self.navigationItem setBackBarButtonItem: [[UIBarButtonItem alloc]
                                                    initWithTitle: @""
                                                    style: UIBarButtonItemStylePlain
                                                    target: nil action: nil]];
        [self.navigationController pushViewController:groups animated:YES];
        [self dissmissView:menuView];
    } onFailure:^(NSError *error) {
        [self dissmissView:menuView];
    }];
    
}

- (void) showMenu
{
    [self popView:menuView];
    //menuView.hidden = NO;
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = MEMBERSHIP_CLASS;
   [self.predicates addObject:[SSFilter on:USER_ID op:EQ value:[SSProfileVC profileId]]];
    self.title = @"Membership";
    self.titleKey = FIRST_NAME;
    self.defaultHeight = 160;
    self.tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    self.addable = YES;
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    search.imageInsets = UIEdgeInsetsMake(2.0, -35.0, 0, 5);
    self.navigationItem.rightBarButtonItems = [self addBarItem: search to:self.navigationItem.rightBarButtonItem];

    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showMenu)];

}

@end
