//
//  SSProfileEditorVC.m
//  Medistory
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//
#import "SSProfileEditorVC.h"
#import <Parse/Parse.h>
#import "SSConnection.h"
#import "SSSecurityVC.h"
#import "SSProfileVC.h"
#import "SSImageEditorVC.h"

#import "SSFriendVC.h"
#import "SSLovTextField.h"
#import "SSApp.h"
#import "SSMessagingVC.h"
#import "SSRoundTextView.h"
#import "SSGroupVC.h"
#import "SSFilter.h"

//#import "SSEventView.h"

#import "SSAddressField.h"
#import "SSRoundButton.h"
#import "SSAppSetupVC.h"
#import "SSImagesVC.h"
//#import "SSResumeVC.h"


@interface SSProfileEditorVC ()<ProcessImageDelegate, SSTableViewVCDelegate>
{
    BOOL isAdmin;
    IBOutlet UIButton *btnFollow;
    IBOutlet UIView *footerView;
    
    IBOutlet UIView *imageView;
    
    IBOutlet UIView *generalView;
    IBOutlet UIView *aboutMeView;
    IBOutlet UIView *actionView;
    IBOutlet UIView *profileView;
    
    IBOutlet SSRoundButton *btnCreateNetwork;
    IBOutlet SSRoundButton *btnMakeAdmin;
    IBOutlet SSRoundButton *btnDeleteAccount;
    
    IBOutlet SSRoundButton *btnCancelAccount;
    IBOutlet SSRoundButton *btnSignOff;
    IBOutlet UIImageView *imgUserType;
    BOOL imageDirty;
    
    NSArray *invites;
    IBOutlet UIButton *btnChat;
    IBOutlet UIButton *btnAccept;
    IBOutlet UIButton *bFriendWith;
    
    NSMutableArray *imageViews;
}

- (IBAction)signoff:(id)sender;
- (IBAction)cancelAccount:(id)sender;
- (IBAction)makeFriend:(id)sender;

- (IBAction)chatWith:(id)sender;

- (IBAction)completeSignup:(id)sender;
- (IBAction)acceptRequest:(id)sender;
- (IBAction) roleBaseSecurity:(id)sender;

@end

@implementation SSProfileEditorVC


- (IBAction)createNetwork:(id)sender {
    SSAppSetupVC *appSetup = [[SSAppSetupVC alloc]init];
    
    [self.navigationController pushViewController:appSetup animated:YES];
}

- (IBAction)makeAdmin:(id)sender
{
    [self.item2Edit setObject:[NSNumber numberWithBool:YES] forKey:IS_ADMIN];
    [self save];
}


- (void) entityDidSave:(id)object
{
    [self uiWillUpdate:object];
}

- (IBAction) roleBaseSecurity:(id)sender
{
    [self.navigationController pushViewController:[[SSGroupVC alloc]init] animated:YES];
}

- (IBAction)completeSignup:(id)sender
{
    [self save];
}

- (IBAction)acceptRequest:(id)sender
{
    [self.friendRequest setValue:ACCEPTED forKey:STATUS];
    [[SSConnection connector] createObject:self.friendRequest ofType:FRIEND_CLASS onSuccess:^(id data) {
         self.friendRequest = data;
         [self uiWillUpdate:self.item2Edit];
     } onFailure:^(NSError *error) {
         //
     }
     ];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if(alertView.tag == 1)
        {
            [SSSecurityVC cancelAccount];
        }
        else if(alertView.tag == 2){
            [SSSecurityVC deleteAccount:self.item2Edit];
        }
    }
}
//cancel my account
- (IBAction)cancelAccount:(id)sender
{
    UIAlertView *alertView =
    [[UIAlertView alloc]initWithTitle:@"Cancel My Account"
                              message:@"Are you sure?" delegate:self
                    cancelButtonTitle:@"Cancel"
                    otherButtonTitles:@"Ok", nil];
    
    alertView.tag = 1;
    [alertView show];
    
}

//to delete someone's account
- (IBAction)deleteAccount:(id)sender
{
    UIAlertView *alertView =
    [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat: @"Delete Account %@", [self.item2Edit objectForKey:USERNAME]]
                              message:@"Are you sure?"
                             delegate:self
                    cancelButtonTitle:@"Cancel"
                    otherButtonTitles:@"Ok", nil];
    alertView.tag = 2;
    [alertView show];
}

-(IBAction) chatWith :(id)sender
{
    SSMessagingVC *msgVC = [[SSMessagingVC alloc]init];
    msgVC.messageWith = self.item2Edit;
    msgVC.chatId = [self.friendRequest objectForKey:REF_ID_NAME];
    [self.navigationController pushViewController:msgVC animated:YES];
}

- (IBAction) makeFriend:(id)sender
{
    [SSFriendVC makeFriendWith:self.item2Edit
                     onSuccess:^(NSDictionary *data) {
                         [self.navigationController popViewControllerAnimated: YES];
                     } onFailure:^(NSError *error) {
                         //
                     }];
}

- (IBAction)signoff:(id)sender
{
    [SSSecurityVC signoff];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super hideKeyboard];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.itemType = PROFILE_CLASS;
        self.tabBarItem.image = [UIImage imageNamed:@"people.png"];
        //self.readonly = YES;
        imageDirty = YES;
    }
    return self;
}

- (void) viewProfile:(NSString *)profileId
           onSuccess: (SuccessCallback) callback
           onFailure: (ErrorCallback) errorCallback
{
    SSConnection *conn =[SSConnection connector];
    
    self.readonly = ![[SSProfileVC profileId] isEqual:profileId];
    
    [conn objectForKey:profileId ofType:self.itemType onSuccess:^(id data) {
       [self updateEntity:data OfType:self.itemType];
        callback(data);
    } onFailure:^(NSError *error) {
        errorCallback(error);
    }];
}
- (void) tableViewVC:(id)tableViewVC didLoad:(id)entity
{
    [layoutTable reloadData];
}
- (void) editMyProfile
{
    SSConnection *conn =[SSConnection connector];
    [conn objects:[NSPredicate predicateWithFormat:@"username=%@", [PFUser currentUser].username ]
           ofType:self.itemType
          orderBy:nil
        ascending:YES
           offset:0
            limit:10
        onSuccess:^(NSDictionary *data) {
            NSArray *profile = [data objectForKey:PAYLOAD];
            if ([profile count] == 0)
            {
                [self updateEntity:nil OfType:self.itemType];
            }
            else
            {
                [self updateEntity: [profile objectAtIndex:0] OfType:self.itemType];
            }
        } onFailure:^(NSError *error) {
            //show alert
        }
     ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [SSSecurityVC checkLogin:self withHint:@"Check Login" onLoggedIn:^(id user) {
        if(user)
        {
            [super viewWillAppear:animated];
        }
        else
        {
            //
        }
    }];
}

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    //self.readonly = !(self.isAuthor || [SSProfileVC isAdmin]) || self.readonly;
    
    if (entity == nil || [entity count] == 0)
    {
        return;
    }
    if (![SSSecurityVC isSignedIn])
    {
        return;
    }
    
    self.title = @"Profile";
    //NSString *profileId =[entity objectForKey:REF_ID_NAME];
    
    bFriendWith.hidden = YES;
    btnAccept.hidden = YES;
    btnChat.hidden = YES;
    
    imgUserType.image = [[SSApp instance] defaultImage:self.item2Edit ofType:USER_TYPE];
    /*
    if(!self.isAuthor)
    {
        [SSFriendVC checkIfIsMyFriend:profileId onComplete:^(id data) {
            if (data && [data count]>0)
            {
                self.friendRequest = [data objectAtIndex:0];
                if(bFriendWith.hidden)
                {
                    btnAccept.hidden = [[self.friendRequest objectForKey:STATUS] isEqualToString:ACCEPTED]
                    || [[self.friendRequest objectForKey:USER_ID] isEqualToString:[SSProfileVC profileId]];
                    btnChat.hidden = YES;
                }
                else
                {
                    btnChat.hidden = YES;
                    btnAccept.hidden = YES;
                    bFriendWith.hidden = NO;
                }
            }
            else
            {
                bFriendWith.hidden = NO;
            }
        }];
    }
    */
    [layoutTable removeChildViews];
    [layoutTable addChildView:imageView];
    
    if(!self.readonly)
    {
        [layoutTable addChildView: generalView];
    }
    
 //   [layoutTable addChildView: profileView];
    [layoutTable addChildView: aboutMeView];
    
    isAdmin = [SSProfileVC isAdmin];
    BOOL myProfile = [[self profileId] isEqualToString:self.item2Edit[REF_ID_NAME]];
    
    
    if (self.readonly && myProfile)
    {
        btnDeleteAccount.hidden = btnMakeAdmin.hidden = !isAdmin;
        btnCancelAccount.hidden = btnSignOff.hidden = !myProfile;
        if ((!btnDeleteAccount.hidden || !btnCancelAccount.hidden  ))
        {
            [layoutTable addChildView: actionView];
        }
    }

    [super doLayout];
    

    
    [layoutTable addChildView:footerView];
    
    [[SSApp instance]customizeProfileEditor:layoutTable];
    
    [self linkEditFields];
    [layoutTable reloadData];
    
    
    btnCreateNetwork.hidden = ![SSApp instance].createNetwork;
}

- (void) entityWillSave:(id)entity
{
    NSString *email = [entity objectForKey:EMAIL];
    if ([[email componentsSeparatedByString:@"@"] count] == 2)
    {
        NSString *domain = [[email componentsSeparatedByString:@"@"] objectAtIndex:1];
        [entity setObject:domain forKey:DOMAIN_NAME];
        [entity setObject:email forKey:EMAIL];
    }
    NSArray *searchwords = [NSArray arrayWithObjects: [entity objectForKey:FIRST_NAME],[entity objectForKey:LAST_NAME], [[SSApp instance] value:entity forKey: [entity objectForKey:JOB_TITLE]],nil];
    
    
    [entity setObject: [searchwords toKeywordList] forKey:SEARCHABLE_WORDS];
}

- (SSTableViewVC *) createSearchVC
{
    SSProfileVC *search = [[SSProfileVC alloc]init];
    search.objectType = self.itemType;
    search.entityEditorClass = [[SSApp instance] editorClassFor:search.objectType];
    return search;
}

@end
