//
//  SSClientTableVC.m
//  Mappuccino
//
//  Created by Anping Wang on 4/7/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSClientTableVC.h"
#import "SSSearchCell.h"
#import "SSSimpleCell.h"

@interface SSClientTableVC ()

@end

@implementation SSClientTableVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
        self.objectType =  @"com.iswim.model.Swimmer";//@"org.twc.model.Roaster";
        self.orderBy=@"dateCreated,desc";
        self.tabBarItem.title = nil;
        self.tabBarItem.image = [UIImage imageNamed:@"06-magnify"];
        self.offset = 0;
        self.pageSize = 20;
        self.queryString = WILD_SEARCH_CHAR;
    }
    return self;
}

- (void) forceReload:(UIRefreshControl *) refreshControl
{
    [self invalidateCache];
    [refreshControl endRefreshing];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(forceReload:)
             forControlEvents:UIControlEventValueChanged];
    [objectsTableView addSubview:refreshControl];
}

- (BOOL) doesString:(NSString *) searchText matchWordsIn:(NSArray *) words
{
    for (NSString *word in words)
    {
        if ( [[word uppercaseString] hasPrefix : [searchText uppercaseString]] )
        {
            return YES;
        }
    }
    return NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.queryString = searchText;

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    self.offset = 0;
    self.dataObjects = [NSMutableArray array];
    [self getObjects];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void) updateUI
{
    [super updateUI];
    [objectsTableView reloadData];
}

- (void) onError:(id)error
{
    [[[UIAlertView alloc]initWithTitle:@"Error"
                               message:[NSString stringWithFormat:@"%@", error]
                              delegate:self
                     cancelButtonTitle:@"Close"
                     otherButtonTitles:nil] show];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        if (self.offset + self.pageSize < self.total)
        {
            self.offset += self.pageSize;
            [self getObjects];
        }
    }
}

- (BOOL) configCell:(SSSearchCell *) searchCell forItem:(id) item
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataObjects count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self delete:[self.dataObjects objectAtIndex:indexPath.row]];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *searchCellIdentifier = @"SSSearchCellId";
    SSSearchCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSSearchCell" owner:self options:nil];
    	cell = (SSSearchCell *)[nib objectAtIndex:0];
    }
    id item = [self.dataObjects objectAtIndex:indexPath.row];
    if (![self configCell:cell forItem:item])
    {
        DebugLog(@"You must implement configCell to display search results");
    }
    return cell;
}
@end
