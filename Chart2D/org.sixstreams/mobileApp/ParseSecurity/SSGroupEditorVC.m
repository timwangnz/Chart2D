//
//  SSGroupEditorVC.m
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSGroupEditorVC.h"
#import "SSConnection.h"
#import "SSProfileVC.h"
#import "SSSearchVC.h"
#import "SSRoundView.h"
#import "SSMembershipVC.h"
#import "SSApp.h"
#import <Parse/Parse.h>

@interface SSGroupEditorVC ()<SSTableViewVCDelegate, SSListOfValueDelegate>
{
    IBOutlet SSRoundView *controlView;
  
    IBOutlet UIView *mainView;
    IBOutlet UIView *footerView;
    
    
    __weak IBOutlet UIImageView *imgPublic;
    __weak IBOutlet UIImageView *imgPrivate;
   
  
    IBOutlet UIView *invitesView;
    
    IBOutlet UIButton *bInvite, *bJoin,*bLeave, *bDelete;
    
    IBOutlet SSSearchVC *vcMembership;
}

@end

@implementation SSGroupEditorVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.itemType = GROUP_CLASS;
        self.tabBarItem.image = [UIImage imageNamed:@"111-user.png"];
        self.readonly = YES;
    }
    return self;
}

- (IBAction) changePrivacy:(UIButton *)sender
{
    int currentValue = [self.item2Edit[PRIVACY] intValue] ;
    if (currentValue != sender.tag)
    {
        self.item2Edit[PRIVACY] = [NSNumber numberWithInt:(int) sender.tag];
        self.valueChanged = YES;
        [self updatePrivacy];
    }
}

- (void) updatePrivacy
{
    BOOL isprivate = [self.item2Edit[PRIVACY] intValue] == 1;
    imgPrivate.image = [UIImage imageNamed:isprivate ? @"PageCreateGroup_EmptyCheckMark.png" : @"PageCreateGroup_CheckMark.png"];
    imgPublic.image = [UIImage imageNamed:isprivate ? @"PageCreateGroup_CheckMark.png" : @"PageCreateGroup_EmptyCheckMark.png"];
}


- (void) listOfValues:(id)tableView didSelect:(id)entity
{
    if (![self isMember:entity])
    {
        [SSMembershipVC user: entity join: self.item2Edit onSuccess:^(NSDictionary *data) {
            [vcMembership refreshOnSuccess:^(id data) {
                [vcMembership refreshUI];
            } onFailure:^(NSError *error) {
                //
            }];
        }];
    }
}

- (IBAction)invite:(id)sender
{
    SSProfileVC *lov = [[SSProfileVC alloc]init];
    lov.listOfValueDelegate = self;
    [lov refreshOnSuccess:^(id data) {
        
        [self.navigationItem setBackBarButtonItem: [[UIBarButtonItem alloc]
                                                   initWithTitle: @""
                                                   style: UIBarButtonItemStyleBordered
                                                    target: nil action: nil]];
         [self.navigationController pushViewController:lov animated:YES];
    } onFailure:^(NSError *error) {
        //
    }];
}


- (IBAction)join:(id)sender
{
    [SSMembershipVC user: [SSProfileVC profile] join: self.item2Edit onSuccess:^(NSDictionary *data) {
        [vcMembership refreshOnSuccess:^(id data) {
            [vcMembership refreshUI];
            bJoin.hidden = YES;
            bLeave.hidden = ! bJoin.hidden;
        } onFailure:^(NSError *error) {
            //
        }];
    }];
}

- (IBAction)leave:(id)sender {
    
    [SSMembershipVC user:[SSProfileVC profileId] leave:self.item2Edit[REF_ID_NAME] onSuccess:^(id data) {
        [vcMembership refreshOnSuccess:^(id data) {
            [vcMembership refreshUI];
            bJoin.hidden = NO;
            bLeave.hidden = ! bJoin.hidden;
        } onFailure:^(NSError *error) {
            //
        }];
    }];
    
}

- (void) tableView:(id)tableView didLoad:(id)objects
{
    bJoin.hidden = [self isMember:[SSProfileVC profile]];
    bInvite.hidden = !bJoin.hidden;
}

- (void) tableViewVC:(id)tableViewVC didSelect:(id)entity
{
    [[SSConnection connector] objectForKey: entity[USER_ID] ofType:PROFILE_CLASS onSuccess:^(id data) {
        SSEntityEditorVC *profileEditor = [[SSApp instance] entityVCFor : PROFILE_CLASS];
        profileEditor.readonly = YES;
        profileEditor.item2Edit = data;
        [self.navigationController pushViewController:profileEditor animated:YES];
    } onFailure:^(NSError *error) {
        //
    }];

}

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    
    layoutTable.tableHeaderView = iconView;
    [layoutTable addChildView:mainView];
    
    if (self.readonly)
    {
        if(vcMembership)
        {
            vcMembership.objectType = MEMBERSHIP_CLASS;
            vcMembership.titleKey = [NSString stringWithFormat:@"%@ %@", FIRST_NAME, LAST_NAME];
            vcMembership.iconKey = USER_ID;
            vcMembership.defaultIconImgName = @"people";
            vcMembership.editable = [[self profileId] isEqualToString:self.item2Edit[AUTHOR]];
            [vcMembership.predicates addObject:[SSFilter on:GROUP_ID op:EQ value:[entity objectForKey:REF_ID_NAME]]];
            vcMembership.tableViewDelegate = self;
            [vcMembership refreshOnSuccess:^(id data) {
                [vcMembership refreshUI];
            } onFailure:^(NSError *error) {
                //
            }];
        }
        
        [SSMembershipVC user:[self profileId] isMemberOfGroup:self.item2Edit[REF_ID_NAME]
                   onSuccess:^(id data) {
            bJoin.hidden = [data count] == 1 || [entity[PRIVACY] intValue] == 0;
            bLeave.hidden = [data count] != 1 || !bInvite.hidden;
        }];
        
        iconView.owner = [self.item2Edit objectForKey:USERNAME];
        iconView.url = [self.item2Edit objectForKey:REF_ID_NAME];
        self.title = self.item2Edit[NAME];
        
        [layoutTable addChildView:invitesView];
    }
    else
    {
        if(!self.item2Edit[PRIVACY])
        {
            self.item2Edit[PRIVACY] = [NSNumber numberWithInt:0];
        }
    }
    
    [layoutTable addChildView:footerView];
    
    [self updatePrivacy];
    [self linkEditFields];
    
   
    vcMembership.editable = self.isAuthor;
    bInvite.hidden =  !vcMembership.editable;
    if ([self.item2Edit[AUTHOR] isEqualToString:[self profileId]] && self.readonly)
    {
        self.navigationItem.rightBarButtonItems = @[
                                                    [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(edit:)]
                                                    ];
        
    }
    
    bDelete.hidden = !self.isAuthor;
    [layoutTable reloadData];
    mainView.userInteractionEnabled = !self.readonly;//(self.isAuthor||self.isCreating);
}

- (BOOL) isMember:(id) user
{
    for (id membership in vcMembership.objects)
    {
        if ([[membership objectForKey:USER_ID] isEqualToString:[user objectForKey:REF_ID_NAME]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) entityShouldSave:(id) object
{

        return YES;
    
}

- (void) entityDidSave:(id)object
{
    if(self.isCreating)
    {
        //need to create a group here
        self.isCreating = NO;
        [SSMembershipVC user: [SSProfileVC profile] join:object onSuccess:^(NSDictionary *data) {
            //do nothing here
        }];
    }
}

@end
