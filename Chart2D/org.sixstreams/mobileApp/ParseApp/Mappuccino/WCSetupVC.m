//
//  WCSetupVC.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/6/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCSetupVC.h"
#import "WCRoasterCell.h"
#import "WCRoasterDetailsVC.h"
#import "SSProfileVC.h"
#import "SSSecurityVC.h"

static NSString* _WC_SETUP_KEY = @"MySetup";
@interface WCSetupVC ()

@end

@implementation WCSetupVC

static NSString *_ACTIVATION_CODE =@"williamchong";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Setup", @"Setup");
        self.tabBarItem.image = [UIImage imageNamed:@"19-gear"];
        
    }
    return self;
}

- (IBAction)syncNow:(id)sender
{
  
    
}

+ (NSString *) getUsername
{
    return [SSSecurityVC username];
}

+ (BOOL) isAdmin
{
    return [[[SSProfileVC profile] objectForKey:@"activationCode"] isEqualToString:_ACTIVATION_CODE];
}

- (IBAction)cancel:(id)sender
{
    [username resignFirstResponder];
    [code resignFirstResponder];
    [email resignFirstResponder];
}

- (void) dataDidLoad: (NSArray *)data
{
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]; // 1
    NSArray * sortedArray = [data sortedArrayUsingDescriptors: [NSArray arrayWithObject:descriptor]];
    
    filteredRoasters = [[NSMutableArray alloc] init];
    for (NSDictionary *roaster in sortedArray)
    {
            if ([@"published" isEqualToString:[roaster objectForKey:@"status"]])
            {
                continue;
            }
            else
            {
                [filteredRoasters addObject:roaster];
            }
    }
    [tableViewRoasters reloadData];
    tableViewRoasters.hidden = [filteredRoasters count] == 0;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void) dataFailedToLoad:(NSString *)error
{
    [[[UIAlertView alloc]initWithTitle:@"Error" message:error delegate:self cancelButtonTitle:@"Closs" otherButtonTitles:nil] show];
}

- (IBAction)updateParameter:(id)sender
{
    [setupParemeter setObject:username.text ? username.text : @""  forKey:@"username"];
    [setupParemeter setObject:email.text ? email.text : @"" forKey:@"email"];
    [setupParemeter setObject:code.text ? code.text : @"" forKey:@"activationCode"];
    
    
    if ([code.text isEqualToString:_ACTIVATION_CODE])
    {
        adminMode.hidden = NO;
        code.hidden = YES;
        [self syncNow:sender];
    }
    else{
        adminMode.hidden = YES;
        code.hidden = NO;
    }
    
    [username resignFirstResponder];
    [code resignFirstResponder];
    [email resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    username.text = [setupParemeter objectForKey:@"username"];
    email.text = [setupParemeter objectForKey:@"email"];
    code.text = [setupParemeter objectForKey:@"activationCode"];
    if ([code.text isEqualToString:_ACTIVATION_CODE])
    {
        adminMode.hidden = NO;
        code.hidden = YES;
    }
    else{
        adminMode.hidden = YES;
        code.hidden = NO;
    }
    saveBtn.hidden = [WCSetupVC isAdmin];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    tableViewRoasters.hidden = YES;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedObject = [filteredRoasters objectAtIndex:indexPath.row];
    WCRecommendVC *viewController3 = [[WCRecommendVC alloc] initWithNibName:@"WCRecommendVC" bundle:nil];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:viewController3 animated:YES];
    [viewController3 edit:selectedObject];
    viewController3.title = @"Edit";
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredRoasters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCRoasterCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"WCRoasterCellId"];
    if (cell == nil)
    {
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"WCRoasterCell" owner:self options:nil];
        cell = (WCRoasterCell *) [bundle objectAtIndex:0];
    }
    
    [cell configCell:[filteredRoasters objectAtIndex:indexPath.row]];
    return cell;
}

@end
