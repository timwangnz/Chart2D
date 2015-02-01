//
//  SSActivityVC.m
//  SixStreams
//
//  Created by Anping Wang on 3/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSActivityVC.h"
#import "SSActivityView.h"
#import "SSApp.h"

@interface SSActivityVC ()
{

    IBOutlet SSActivityView *vActivityView;
}

@end

@implementation SSActivityVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.objectType = SOCIAL_ACTIVITY;
        self.tabBarItem.image = [UIImage imageNamed:@"green"];
        self.title = @"Activities";
        self.appendOnScroll = NO;
        self.pullRefresh = YES;
        self.orderBy = CREATED_AT;
        self.ascending = NO;
        
    }
    return self;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(int) row col:(int) col
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"SSActivityView" owner:nil options:nil];
    SSActivityView *view = [nibContents lastObject];
    view.activity = [self.objects objectAtIndex:row];
    view.frame = cell.frame;
    return view;
}

- (void) onSelect:(id) object
{
    
    UIViewController *details = [[SSApp instance] createVCForActivity:object];
    if (details)
        [self.navigationController pushViewController:details animated:YES];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self forceRefresh];
}

@end
