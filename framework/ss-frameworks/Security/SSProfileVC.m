//
//  SSMeetUpVC.m
//  Medistory
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//
#import "SSApp.h"
#import "SSFilter.h"
#import "SSProfileVC.h"
#import "SSProfileEditorVC.h"
#import "SSSecurityVC.h"
#import <Parse/Parse.h>
#import "SSConnection.h"
#import "SSImageView.h"
#import "SSTableViewCell.h"
#import "SSNearByVC.h"
#import "SSMembershipVC.h"
#import "SSMessagingVC.h"

@interface SSProfileVC ()<UISearchBarDelegate, SSNearByDelegate>
{
    IBOutlet UIView *vToolbar;
    IBOutlet UISearchBar *searchBar;
     NSString *category;
    UIButton *lastBtn;
    IBOutlet UIButton *btnCancel;
    int toolbarItems;
}

- (IBAction)searchByType:(UIButton *)sender;
- (IBAction)cancelSearch:(id)sender;

@end

@implementation SSProfileVC

+ (void) createNewProfile: (id) newProfile
                onSuccess: (SuccessCallback) callback
                onFailure: (ErrorCallback) errorCallback
{
    PFUser *user =[PFUser currentUser];
    SSConnection *conn =[SSConnection connector];
    
    [newProfile setObject:user.email? user.email : @"" forKey:EMAIL];
    [newProfile setObject:user.username forKey:USERNAME];
    [newProfile setObject:user.objectId forKey:USER_ID];
    
    [newProfile setValue:[[SSApp instance] displayName] forKey:@"appName"];
    [newProfile setValue:[[SSApp instance] welcomeMessage] forKey:@"message"];
    [newProfile setValue:[[SSApp instance] email] forKey:@"appEmail"];
    NSString *email = user.email;
    
    if ([[email componentsSeparatedByString:@"@"] count] ==2)
    {
        NSString *domain = [[email componentsSeparatedByString:@"@"] objectAtIndex:1];
        [newProfile setObject:domain forKey:DOMAIN_NAME];
    }
    
    [conn createObject:newProfile
                ofType:PROFILE_CLASS
             onSuccess:^(NSDictionary *data){
                 callback(data);
             }
             onFailure:^(NSError *error) {
                 errorCallback(error);
             }
     ];
}


+ (NSString *) profileId
{
    return [[self profile] valueForKey:REF_ID_NAME];
}

+ (BOOL) isAdmin
{
    return [[[self profile] valueForKey:IS_ADMIN]boolValue];
}

+ (NSString *) name
{
    return [NSString stringWithFormat:@"%@ %@", [[self profile] objectForKey:FIRST_NAME], [[self profile] objectForKey:LAST_NAME]];
}

+ (NSString *) domainName
{
    NSString *domain = [[SSProfileVC profile] objectForKey: DOMAIN_NAME];
    if (domain == nil)
    {
        PFUser *user =[PFUser currentUser];
        NSString *email = user.email;
        
        if ([[email componentsSeparatedByString:@"@"] count] ==2)
        {
            NSString *domain = [[email componentsSeparatedByString:@"@"] objectAtIndex:1];
            return domain;
        }
        return @"unknown domain";
    }
    else{
        return domain;
    }
}
static PFGeoPoint * pfGeoPoint;
+ (PFGeoPoint *) currentLocation
{
    if(!pfGeoPoint)
    {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            pfGeoPoint = geoPoint;
        }];
    }
    return pfGeoPoint;
}

+ (id) profile
{
    return [SSSecurityVC profile];
}

+ (void) followingsOnComplete:(SuccessCallback) callback;
{
    PFUser *user =[PFUser currentUser];
    if (!user.isAuthenticated)
    {
        return;
    }
    
    SSConnection *conn =[SSConnection connector];
    [conn objects:[NSPredicate predicateWithFormat:@"by=%@", [self profileId] ]
           ofType:SOCIAL_FOLLOW
          orderBy:CREATED_AT
        ascending:NO
           offset:0
            limit:40
        onSuccess:^(id data) {
            callback(data);
        } onFailure:^(NSError *error) {
            //
        }];
}

+ (void) getProfile:(NSString *)userId
         onComplete:(SSCallBack) callback
{
    SSConnection *conn =[SSConnection connector];
    [conn objectForKey:userId ofType:PROFILE_CLASS
              onSuccess:^(id data) {
                  callback(data);
              } onFailure:^(NSError *error) {
                  //
              }
     ];
}

- (void) addToolButton
{
    NSDictionary *types = [[SSApp instance] lookupsFor:USER_TYPE];
    toolbarItems = 0;
    for(NSString *type in [types allKeys])
    {
        UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(2+(toolbarItems++)*34, 4, 32, 32)];
        [btn setImage:[[SSApp instance] defaultImage: @{USER_TYPE: type} ofType:USER_TYPE] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"check-selected.png"] forState:UIControlStateSelected];
        btn.tag = [type intValue];
        [btn addTarget:self action:@selector(searchByType:) forControlEvents:UIControlEventTouchUpInside];
        [vToolbar addSubview:btn];
    }
    
    float width = toolbarItems * 34 + 2;
    vToolbar.frame = CGRectMake(self.view.frame.size.width - width, vToolbar.frame.origin.y, width, vToolbar.frame.size.height);
   // searchBar.frame = CGRectMake(searchBar.frame.origin.x , searchBar.frame.origin.y, self.view.frame.size.width - width, searchBar.frame.size.height);
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = PROFILE_CLASS;
    self.title = @"People";
    self.tabBarItem.title = self.title;
    self.tabBarItem.image = [UIImage imageNamed:@"112-group.png"];
    self.addable = NO;
    self.queryPrefixKey = SEARCHABLE_WORDS;
    self.orderBy = UPDATED_AT;
    self.appendOnScroll = YES;
}

- (NSString *) getCellText:(id) rowItem atCol:(int) col
{
    return [NSString stringWithFormat:@"%@ %@",
            [rowItem objectForKey:FIRST_NAME],
            [rowItem objectForKey:LAST_NAME]
            
            ];
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
    
    if(self.listOfValueDelegate && [self.listOfValueDelegate respondsToSelector:@selector(listOfValues:isSelected:)])
    {
        if([self.listOfValueDelegate listOfValues:self isSelected:item])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    cell.icon.defaultImg = [UIImage imageNamed:PERSON_DEFAULT_ICON];
    
    cell.icon.owner = [item objectForKey:USERNAME];
    cell.icon.url = [item objectForKey:REF_ID_NAME];
    cell.title.text =   [NSString stringWithFormat:@"%@ %@", [item objectForKey:FIRST_NAME], [item objectForKey:LAST_NAME]];
    cell.author.text = [[SSApp instance] value:item forKey:USER_TYPE];
    cell.subtitle.text = [item objectForKey:EMAIL];

    //cell.metaIcon.image = [[SSApp instance] defaultImage:item ofType:USER_TYPE];
    
    return cell;
}

- (void) logout
{
    [SSSecurityVC signoff];
}

- (void) showMyProfile
{
    [SSSecurityVC checkLogin:self withHint:@"Singin" onLoggedIn:^(id user) {
        SSProfileEditorVC *myProfile =(SSProfileEditorVC*) [[SSApp instance] entityVCFor:PROFILE_CLASS];
        myProfile.readonly = YES;
        [myProfile updateEntity:[SSProfileVC profile] OfType:PROFILE_CLASS];
        [myProfile editMyProfile];
        myProfile.title = @"My Profile";
        [self.navigationController pushViewController:myProfile animated:YES];
    }];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if(!self.listOfValueDelegate)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style: UIBarButtonItemStylePlain target:self action:@selector(showMapView)];
    }
    self.objectType = PROFILE_CLASS;
    [SSProfileVC currentLocation];
    [self addToolButton];
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    SSProfileEditorVC *entityEditor =(SSProfileEditorVC*) [[SSApp instance] entityVCFor:PROFILE_CLASS];
    [entityEditor updateEntity:item OfType: self.objectType];
    entityEditor.title = @"Profile";
    entityEditor.readonly = YES;
    return entityEditor;
}

#pragma search

- (BOOL) clearTitleFilter
{
    SSFilter *filter2clear;
    
    for (SSFilter *filter in self.predicates) {
        if ([filter.attrName isEqualToString: USER_TYPE]) {
            filter2clear = filter;
            break;
        }
    }
    
    if (filter2clear)
    {
        [self.predicates removeObject:filter2clear];
        return YES;
    }
    return NO;
}

- (IBAction)searchByType:(UIButton *)sender
{
    if (lastBtn == sender)
    {
        [sender setSelected:!sender.isSelected];
        lastBtn = sender;
    }else
    {
        lastBtn.selected = NO;
        sender.selected = YES;
        lastBtn = sender;
    }
    
    [searchBar resignFirstResponder];
    [self clearTitleFilter];
    [self.predicates removeAllObjects];
    
    if(sender.selected)
    {
        [self.predicates addObject:[SSFilter on:USER_TYPE op:EQ value:[NSString stringWithFormat:@"%i", (int) sender.tag]]];
    }
    [self forceRefresh];
}

- (IBAction)cancelSearch:(id)sender
{
    [searchBar endEditing:YES];
    [self hideSearchBar];
}

- (void) hideSearchBar
{
    [UIView animateWithDuration:0.4 animations:^{
        vToolbar.alpha = 0;
        CGRect rect = searchBar.frame;
        rect.size.width = self.view.frame.size.width - vToolbar.frame.size.width;
        vToolbar.alpha = 1;
        searchBar.frame = rect;
        btnCancel.hidden = YES;
    }];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)theSearchBar
{
    [self hideSearchBar];
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)theSearchBar
{
    [UIView animateWithDuration:0.4 animations:^{
        [self clearTitleFilter];
        vToolbar.alpha = 1;
        CGRect rect = searchBar.frame;
        rect.size.width = self.view.frame.size.width - btnCancel.frame.size.width - 2;
        searchBar.frame = rect;
        vToolbar.alpha = 0;
        btnCancel.hidden = NO;
    }];
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]==0)
    {
        self.queryPrefix = nil;
        [self forceRefresh];
        [theSearchBar resignFirstResponder];
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    self.queryPrefix = [theSearchBar.text lowercaseString];
    self.showBusyIndicator = YES;
    [theSearchBar resignFirstResponder];
    [self refreshOnSuccess:^(id data) {
        [self refreshUI];
    } onFailure:^(NSError *error) {
        //
    }];
    
}

#pragma mapview

- (void) mapView:(id) view didSelect : (id) item;
{
    SSEntityEditorVC *entityEditor = [[SSApp instance] entityVCFor:PROFILE_CLASS];
    [entityEditor updateEntity:item OfType: self.objectType];
    entityEditor.title = @"Profile";
    entityEditor.readonly = YES;
    [self.navigationController pushViewController:entityEditor animated:YES];
}

- (NSString *) mapView:(id)view subtitleFor:(id)item
{
    return [[SSApp instance] value:item forKey:USER_TYPE];
}

- (NSString *) mapView:(id)view titleFor:(id)item
{
    return [NSString stringWithFormat:@"%@ %@",[item objectForKey:FIRST_NAME],[item objectForKey:LAST_NAME]];
}

- (id) mapView:(id)view addressFor:(id)item
{
    if (![[item objectForKey:LAST_NAME] isEqualToString:@"Wang"]) {
        return [item objectForKey:ADDRESS];
    }
    else{
        return nil;
    }
}

- (void) showMapView
{
    SSNearByVC *mapView = [[SSNearByVC alloc]init];
    mapView.objectType = PROFILE_CLASS;
    mapView.objects = self.objects;
    mapView.predicates = self.predicates;
    mapView.delegate = self;
    [self.navigationController pushViewController:mapView animated:YES];
}

@end
