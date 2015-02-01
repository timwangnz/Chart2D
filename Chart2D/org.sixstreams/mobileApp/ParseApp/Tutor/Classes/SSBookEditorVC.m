//
//  SSLessonEditorVC.m
//  SixStreams
//
//  Created by Anping Wang on 2/5/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSBookEditorVC.h"
#import "SSValueField.h"
#import "SSProfileVC.h"
#import "SSFriendVC.h"
#import "SSEntityObject.h"

@interface SSBookEditorVC ()<SSListOfValueDelegate, UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UISegmentedControl *stStoreageOption;
    __weak IBOutlet UITableView *tblFriends;
    __weak IBOutlet UISegmentedControl *sgPrivacy;
    __weak IBOutlet UIButton *btnAddFriend;
    IBOutlet SSValueField *tfName;
    IBOutlet SSValueField *category;
    SSFriendVC *friends;
    NSMutableArray *selectedFriends;
    NSMutableArray *localBooks;
    
}

- (IBAction)addFriends:(id)sender;

@end

@implementation SSBookEditorVC

- (void) addToAcl:(id) entity
{
    for(id friend in selectedFriends)
    {
        if ([[entity objectForKey:REF_ID_NAME ] isEqualToString:[friend objectForKey:PROFILE_ID]])
        {
            return;
        }
    }
    NSMutableDictionary *access = [NSMutableDictionary dictionary];
    [access setObject:[entity objectForKey:AUTHOR] forKey:USER_ID];
    [access setObject:[entity objectForKey:REF_ID_NAME] forKey:PROFILE_ID];
    [access setObject:[entity objectForKey:FIRST_NAME] forKey:FIRST_NAME];
    [access setObject:[entity objectForKey:LAST_NAME] forKey:LAST_NAME];
    [selectedFriends addObject:access];
    [tblFriends reloadData];
}

- (void) listOfValues:(id) tableView didSelect : (id) entity
{
    [self addToAcl:entity];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changePrivacy:(id)sender
{
    btnAddFriend.hidden = tblFriends.hidden = sgPrivacy.selectedSegmentIndex == 0;
    if (sgPrivacy.selectedSegmentIndex != 0) {
        [self addToAcl:[SSProfileVC profile]];
    }
    [self.item2Edit setObject:[NSNumber numberWithInt:(int)sgPrivacy.selectedSegmentIndex] forKey:VISIBILITY];
}

- (IBAction)addFriends:(id)sender
{
    friends = [[SSFriendVC alloc]init];
    friends.listOfValueDelegate = self;
    [self.navigationController pushViewController:friends animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tfName.attrName = NAME;
    selectedFriends = [NSMutableArray array];
   
    self.navigationItem.rightBarButtonItems = [[NSMutableArray alloc]initWithObjects:[[UIBarButtonItem alloc]
                                                                                      initWithTitle:@"Save"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(save)], nil];;
}

- (IBAction) cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) uiWillUpdate:(id)entity
{
    if(!tblFriends)
    {
        return;
    }
    
    if(entity)
    {
        tfName.text = [entity valueForKey:NAME];
        tfName.attrName = NAME;
        category.attrName = CATEGORY;
        sgPrivacy.selectedSegmentIndex = [[entity valueForKey:VISIBILITY] intValue];
        btnAddFriend.hidden = tblFriends.hidden = sgPrivacy.selectedSegmentIndex == 0;
        stStoreageOption.selectedSegmentIndex = [[entity valueForKey:STORAGE] intValue];
        category.text = [entity objectForKey:CATEGORY];
        selectedFriends = [entity objectForKey:ACCESS_CONTROL_LIST];
        if (selectedFriends == nil) {
            selectedFriends = [NSMutableArray array];
            [entity setObject:selectedFriends forKey:ACCESS_CONTROL_LIST];
        }
        [tblFriends reloadData];
    }
    else{
        selectedFriends = [NSMutableArray array];
    }
}

- (BOOL) entityShouldSave:(id)object
{
    if (tfName.text == nil || [tfName.text length]==0){
        [self showAlert:@"Name field is required" withTitle:@"Error"];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void) entityWillSave:(id)object
{
    [object setObject:tfName.text forKey:NAME];
    
    [object setObject:[NSNumber numberWithInt:(int)sgPrivacy.selectedSegmentIndex] forKey:VISIBILITY];
    [object setObject:[NSNumber numberWithInt:(int)stStoreageOption.selectedSegmentIndex] forKey:STORAGE];
    [object setObject:[SSProfileVC name] forKey:USERNAME];
    [object setObject:category.text forKey:CATEGORY];
    
    if (sgPrivacy.selectedSegmentIndex != 0)
    {
        [object setObject:selectedFriends forKey:ACCESS_CONTROL_LIST];
    }
    else
    {
        [object setObject:[NSArray array] forKey:ACCESS_CONTROL_LIST];
    }
}


#pragma friends view
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [selectedFriends count];
}

#define CELL @"cell"

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    id item = [selectedFriends objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [item objectForKey:FIRST_NAME], [item objectForKey:LAST_NAME]];
    return cell;
}


@end

