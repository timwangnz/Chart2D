//
//  SSFollowVC.m
//  SixStreams
//
//  Created by Anping Wang on 4/18/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSFollowVC.h"
#import "SSImageView.h"
#import "SSFilter.h"
#import "SSProfileVC.h"
#import "SSProfileEditorVC.h"
#import "SSApp.h"

@interface SSFollowVC ()
{
    IBOutlet SSImageView *icon;
}

@end

@implementation SSFollowVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.addable = NO;
        self.editable = NO;
        self.cancellable = NO;
        self.title = @"";
        self.objectType = SOCIAL_FOLLOW;
        self.limit = 40;
        self.offset = 0;
        self.orderBy = CREATED_AT;
        self.ascending = NO;
        self.pullRefresh = YES;
    }
    return self;
}

- (void) refreshUI
{
    [super refreshUI];
    icon.url = [self.item objectForKey:REF_ID_NAME];
    icon.cornerRadius = 4;
    self.title = [[SSApp instance] displayName:self.showFollowers ? FOLLOWERS : FOLLOWING ofType: SOCIAL_FOLLOW];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:cellForRowAtIndexPath:tableView:)])
    {
        return [self.tableViewDelegate tableViewVC:self cellForRowAtIndexPath: indexPath tableView:tableView];
    }

    
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    id rowItem = [self.objects objectAtIndex:indexPath.row];
    id context = [rowItem objectForKey:CONTEXT];
    
    if (self.showFollowers)
    {
        context = [rowItem objectForKey:USER_INFO];
    }
    
    NSString *itemType = [rowItem objectForKey:CONTEXT_TYPE];
   
    cell.textLabel.text = [context objectForKey:NAME];
    SSImageView *imgView = [[SSImageView alloc]initWithFrame:CGRectMake(4, 4, cell.frame.size.height - 8 , cell.frame.size.height - 8)];
    imgView.cornerRadius = 6;
    

    imgView.defaultImg = [[SSApp instance] defaultImage:context ofType:itemType];
    imgView.url = [context objectForKey:REF_ID_NAME];
    cell.detailTextLabel.text = [context objectForKey:SUBTITLE];
   
    
    [cell.contentView addSubview: imgView];
    return cell;
}


- (void) sync
{
    [self.predicates removeAllObjects];
    if (self.showFollowers)
    {
        [self.predicates addObject:[SSFilter on:FOLLOW op:EQ value:[self.item objectForKey:REF_ID_NAME]]];
    }
    else
    {
        [self.predicates addObject:[SSFilter on:AUTHOR op:EQ value:[self.item objectForKey:REF_ID_NAME]]];
    }
    [self forceRefresh];
}


- (void) setProfile:(id)item
{
    if([item isEqual:item])
    {
        return;
    }
    _item = item;
    [self sync];
}

- (void) onSelect:(id)object
{
    //NSLog(@"%@", object);
    id context = [object objectForKey:CONTEXT];
    NSString *itemType = [object objectForKey:CONTEXT_TYPE];
    
    if (self.showFollowers)
    {
        context = [object objectForKey:USER_INFO];
        itemType = PROFILE_CLASS;
    }
    

    SSConnection *conn =[SSConnection connector];
    [conn objectForKey: [context objectForKey:REF_ID_NAME] ofType:itemType
             onSuccess:^(id data) {
                 SSEntityEditorVC *editor =  [[SSApp instance] entityVCFor:itemType];
                 editor.itemType = itemType;
                 editor.item2Edit = data;
                 editor.readonly = YES;
                 [self showPopup:editor sender:self];
             }
             onFailure:^(NSError *error) {
                 [self showAlert:
                        [NSString stringWithFormat: @"Failed to get context object for %@", itemType ]
                       withTitle:@"Error"];
             }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.item)
    {
        self.item = [SSProfileVC profile];
    }
    else{
        [self sync];
    }
}

@end
