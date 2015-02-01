//
//  SSNavMenuVC.m
//  SixStreams
//
//  Created by Anping Wang on 12/18/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSNavMenuVC.h"
#import "SSCategoryWizardVC.h"
#import "SSConnection.h"
#import "SSProfileEditorVC.h"
#import "SSImageView.h"
#import "SSSecurityVC.h"
#import "SSApp.h"
#import "SSProfileVC.h"
#import "SSFilter.h"

@interface SSNavMenuVC ()<SSTableViewVCDelegate>
{
    NSArray *applications;
    NSMutableArray *sortedSections;
    NSMutableDictionary *sectionedData;
    IBOutlet SSImageView *profileImg;
    IBOutlet UILabel *appTitle;
    BOOL imageDirty;
}

- (IBAction) showSecuritySetting;

@end

@implementation SSNavMenuVC

- (IBAction) showSecuritySetting
{
    SSProfileEditorVC *myProfile = [[SSProfileEditorVC alloc]init];
    [myProfile editMyProfile];
    
    myProfile.title = @"Profile";
    myProfile.readonly = NO;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:myProfile];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.parentViewController presentViewController:nav animated:YES completion:^{
        //
    }];
}

- (void) addCategory :(id) sender
{
    SSCategoryWizardVC *wizard = [[SSCategoryWizardVC alloc]init];
    wizard.menuVC = self;
    wizard.tableViewDelegate = self;
    wizard.title = @"Create Category";
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:wizard];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.parentViewController presentViewController:nav
                                            animated:YES
                                          completion:^{
                                              //
                                          }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.objectType = APP_CATEGORY;
    }
    return self;
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = APP_CATEGORY;
    
    self.title = @"Categories";
    self.addable = YES;
    self.editable = YES;
    //[self.predicates addObject:[SSFilter on: AUTHOR op:EQ value: [SSProfileVC profileId]]];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    id profile = [SSProfileVC profile];
    profileImg.owner = [profile objectForKey:USERNAME];
    profileImg.url = [profile objectForKey:REF_ID_NAME];
    appTitle.text = [SSApp instance].displayName;
    if(self.width > 0)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.width, self.view.frame.size.height);
    }
}

-(id) getMenuItemAtIndex:(NSInteger) index
{
    return [applications objectAtIndex:index];
}

- (void) tableViewVC:(id) tableViewVC didAdd : (id) entity
{
    [self forceRefresh];
}

- (void) tableViewVC:(id) tableViewVC didDelete : (id) entity
{
    [self forceRefresh];
}

- (void) getApplications
{
    SSConnection *syncher = [SSConnection connector];
    [syncher objects:nil
              ofType: APPLICATION
             orderBy: SEQUENCE
           ascending:YES
              offset:0
               limit:200
           onSuccess:^(NSDictionary *data) {
               applications = [data objectForKey:PAYLOAD];
               [self processApplications];
           }
           onFailure:^(NSError *error) {
               DebugLog(@"Error occured %@", error);
           }
     ];
}

- (void) onDataReceived:(id)objects
{
    [super onDataReceived:objects];
    [self processCategories];
}

- (void) processCategories
{
    sortedSections = [NSMutableArray array];
    for (id object in self.objects)
    {
        [sortedSections addObject:object];
    }
    NSArray *sortedArray;
    sortedArray = [sortedSections sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        int first = [[a objectForKey:SEQUENCE] intValue];
        int second = [[b objectForKey:SEQUENCE] intValue];
        return first > second;
    }];
    sortedSections = [NSMutableArray arrayWithArray:sortedArray];
    [self getApplications];
}

- (void) processApplications
{
    sectionedData = [NSMutableDictionary dictionary];
    
    for (id object in applications)
    {
        NSDictionary * item = object;
        NSString *categoryId = [item objectForKey:CATEGORY];
        NSMutableArray *items = [sectionedData objectForKey:categoryId];
        if (!items)
        {
            items = [NSMutableArray array];
            [sectionedData setValue:items forKey:categoryId];
        }
        [items addObject:item];
    }
    
    for( id key in [sectionedData allKeys])
    {
        NSMutableArray *items = [sectionedData objectForKey:key];
        NSArray *sortedArray;
        sortedArray = [items sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [[a objectForKey:SEQUENCE] intValue];
            int second = [[b objectForKey:SEQUENCE] intValue];
            return first > second;
        }];
        items = [NSMutableArray arrayWithArray:sortedArray];
    }
    [self refreshUI];
}

#pragma tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (sortedSections && [sortedSections count]>1)
    {
        return [sortedSections count];
    }
    else
    {
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self deleteObject : [self.objects objectAtIndex:indexPath.row] ofType : self.objectType];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (sortedSections == nil || [sortedSections count] == 0)
    {
        return 0;
    }
    NSDictionary *category = [sortedSections objectAtIndex:section];
    if (!category || [category count] == 0)
    {
        return 0;
    }
    NSString *categoryId = [category objectForKey:REF_ID_NAME];
    return [[sectionedData objectForKey:categoryId] count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *category = [sortedSections objectAtIndex:indexPath.section];
    
    NSArray *apps = [sectionedData objectForKey:[category objectForKey:REF_ID_NAME]];
    
    NSDictionary *selected = [apps objectAtIndex:indexPath.row];
    self.title = [selected objectForKey:NAME];
    
    selectedPath = indexPath;
    
    if (self.delegate)
    {
        [self.delegate navMenu:self itemSelected:selected];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *category = [sortedSections objectAtIndex:indexPath.section];
    NSArray *apps = [sectionedData objectForKey:[category objectForKey:REF_ID_NAME]];
    
    NSDictionary *device = [apps objectAtIndex:indexPath.row];
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = device ? [device objectForKey:NAME] : @"Not valid";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([sortedSections count] < 2)
    {
        return 1;//hide section
    }
    else{
        return 32;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //we dont want to sectionized the menu if there is only one section
    if ([sortedSections count] < 2)
    {
        return nil;
    }
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10,0,300,28)];
    NSDictionary *cat = [sortedSections objectAtIndex:section];
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.frame = CGRectMake(10,0,200,28);
    headerLabel.text =  [cat objectForKey:DESC];
    headerLabel.textColor = [UIColor grayColor];
    
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor darkGrayColor];
    detailLabel.text = [cat objectForKey:NAME];
    detailLabel.font = [UIFont systemFontOfSize:12];
    detailLabel.frame = CGRectMake(200,2,100,28);
    customView.backgroundColor = [UIColor blackColor];
    [customView addSubview:headerLabel];
    
    return customView;
}

@end
