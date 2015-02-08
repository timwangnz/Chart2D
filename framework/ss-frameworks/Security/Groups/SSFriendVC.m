//
//  SSFriendVC.m
//  Medistory
//
//  Created by Anping Wang on 11/7/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSFriendVC.h"
#import "SSSecurityVC.h"
#import "SSFilter.h"
#import "SSImageView.h"
#import <Parse/Parse.h>
#import "SSProfileEditorVC.h"
#import "SSProfileVC.h"
#import "SSTableViewCell.h"
#import "SSMessagingVC.h"

#define FRIEND_WITH @"friendWith"
#define FRIEND_ID @"friendId"
#define FRIEND_USERNAME @"friendUsername"

@interface SSFriendVC ()

@end

@implementation SSFriendVC

+ (void) checkIfIsMyFriend: (NSString *)userId
                onComplete: (SuccessCallback) callback
{
    SSConnection *conn =[SSConnection connector];
    NSMutableArray *predicates = [NSMutableArray array];
    
    [predicates addObject:[SSFilter on:CONNECTION
                                    op:EQ
                                 value:[SSProfileVC profileId]]];
    [predicates addObject:[SSFilter on:CONNECTION
                                    op:EQ
                                 value:userId]];
    
    [conn objectsWithFilters: predicates
                      ofType: FRIEND_CLASS
                     orderBy: nil
                   ascending: YES
                      offset: 0
                       limit: 1
                   onSuccess:^(id data) {
                       callback([data objectForKey:@"data"]);
                   } onFailure:^(NSError *error) {
                       //
                   }];
}

+ (void) makeFriendWith: (id) friendProfile
              onSuccess: (SuccessCallback) callback
              onFailure: (ErrorCallback) errorCallback
{
    NSMutableDictionary *friend = [NSMutableDictionary dictionary];
    
    [friend setValue:[friendProfile objectForKey:REF_ID_NAME] forKey:FRIEND_ID];
    [friend setValue:[SSProfileVC profileId]forKey:USER_ID];
    [friend setValue:[SSSecurityVC username]forKey:USERNAME];
    [friend setValue:[friendProfile objectForKey:USERNAME] forKey:FRIEND_USERNAME];
    
    [friend setValue:REQUESTED forKey:STATUS];
    [friend setValue:[NSArray arrayWithObjects:[friendProfile objectForKey:REF_ID_NAME],[SSProfileVC profileId], nil] forKey:CONNECTION];
    
    id requester = [NSMutableDictionary dictionary];
    
    id profile = [SSProfileVC profile];
    
    [requester setValue:[profile objectForKey:FIRST_NAME] forKey:FIRST_NAME];
    [requester setValue:[profile objectForKey:LAST_NAME] forKey:LAST_NAME];
    [requester setValue:[profile objectForKey:GROUP] forKey:GROUP];
    [requester setValue:[profile objectForKey:JOB_TITLE] forKey:JOB_TITLE];
    
    id requested = [NSMutableDictionary dictionary];
    
    [requested setValue:[friendProfile objectForKey:FIRST_NAME] forKey:FIRST_NAME];
    [requested setValue:[friendProfile objectForKey:LAST_NAME] forKey:LAST_NAME];
    [requested setValue:[friendProfile objectForKey:GROUP] forKey:GROUP];
    [requested setValue:[friendProfile objectForKey:JOB_TITLE] forKey:JOB_TITLE];
    
    [friend setValue:requester forKey:REQUESTER];
    [friend setValue:requested forKey:REQUESTED];
    
    SSConnection *conn = [SSConnection connector];
    
    [conn createObject:friend ofType:FRIEND_CLASS
             onSuccess:^(NSDictionary *data) {
                 if(callback)
                 {
                     callback(data);
                 }
             } onFailure:^(NSError *error) {
                 errorCallback(error);
             }];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SSTableViewCell *cell = (SSTableViewCell*)[tableView dequeueReusableCellWithIdentifier:SSTableViewCellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSTableViewCell" owner:self options:nil];
        cell = (SSTableViewCell *)[nib objectAtIndex:0];
    }
    
    id item = [self.objects objectAtIndex:indexPath.row];
    id friend = [item objectForKey:REQUESTED];
    cell.icon.defaultImg = [UIImage imageNamed:PERSON_DEFAULT_ICON];
    
    if ([[SSProfileVC profileId] isEqualToString:[item objectForKey:USER_ID]])
    {
        cell.icon.owner = [item objectForKey:FRIEND_USERNAME];
        cell.icon.url = [item objectForKey:FRIEND_ID];
    }
    else
    {
        cell.icon.owner = [item objectForKey:USERNAME];
        cell.icon.url = [item objectForKey:USER_ID];
        friend = [item objectForKey:REQUESTER];
    }
    
    cell.author.text =   [NSString stringWithFormat:@"%@ %@",
                          [friend objectForKey:FIRST_NAME],
                          [friend objectForKey:LAST_NAME]];
    
    cell.title.text  =
    [NSString stringWithFormat:@"%@, %@", [friend objectForKey: JOB_TITLE], [friend objectForKey: GROUP] ? [friend objectForKey: GROUP] : @"Unknown"];
    
    cell.subtitle.text = [NSString stringWithFormat:@"%@", [item valueForKey:STATUS]];
    return cell;
}

- (void) findFriends
{
    SSProfileVC *findVC = [[SSProfileVC alloc]init];
    [findVC.predicates addObject:[SSFilter on:OBJECT_ID op:NE value:[[SSProfileVC profile] objectForKey:REF_ID_NAME]]];
    [self.navigationController pushViewController:findVC animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    if (self.findAllowed) {
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Find"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(findFriends)];
        NSMutableArray *arrBtns = [[NSMutableArray alloc]init];
        [arrBtns addObject:cancelBtn];
        self.navigationItem.rightBarButtonItems = arrBtns;

    }
    else{
        self.navigationItem.rightBarButtonItems = nil;
    }
    
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = FRIEND_CLASS;
    
    self.title = @"Friends";
    self.tabBarItem.title = @"Friends";
    self.tabBarItem.image = [UIImage imageNamed:@"mind_map-32.png"];
    self.addable = NO;
    
    self.queryPrefixKey = FRIEND_ID;
    [self.predicates addObject:[SSFilter on:CONNECTION
                                         op:EQ
                                      value:[SSProfileVC profileId]]];
}

- (void) onSelect:(id) friendRequest
{
    id profileFromServer;
    NSString *profileId = nil;
    if ([[SSProfileVC profileId] isEqualToString:[friendRequest objectForKey:USER_ID]])
    {
        profileId = [friendRequest objectForKey:FRIEND_ID];
        
    }
    else
    {
        profileId =[friendRequest objectForKey:USER_ID];
    }
    
    profileFromServer= [[SSConnection connector]
                        objectForKey:profileId
                        ofType:PROFILE_CLASS];
    
    if (profileFromServer == nil)
    {
        [self showAlert:@"Your friend is no longer with us" withTitle:@"Aler"];
        [[SSConnection connector] deleteObjectById:[friendRequest objectForKey:REF_ID_NAME] ofType:FRIEND_CLASS];
        [self forceRefresh];
        return;
    }
    
    if (self.listOfValueDelegate)
    {
        [self.listOfValueDelegate listOfValues:self didSelect:profileFromServer];
        return;
    }
    
    if([[friendRequest objectForKey:STATUS] isEqualToString:REQUESTED])//show profile
    {
        SSProfileEditorVC *profileVC = [[ SSProfileEditorVC alloc]init];
        profileVC.readonly = YES;
        [profileVC updateEntity:profileFromServer OfType:PROFILE_CLASS];
        [self.navigationController pushViewController:profileVC animated:YES];
    }
    else
    {
        SSMessagingVC *msgVC = [[ SSMessagingVC alloc]init];
        msgVC.messageWith = profileFromServer;
        msgVC.chatId = [friendRequest objectForKey:REF_ID_NAME];
        [self.navigationController pushViewController:msgVC animated:YES];
    }

}

@end
