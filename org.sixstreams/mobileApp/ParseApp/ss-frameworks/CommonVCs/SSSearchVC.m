//
//  SSSearchVC
//  Created by Anping Wang on 9/16/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSSearchVC.h"
#import "SSTableViewCell.h"

#import "WCRoasterDetailsVC.h"
#import "WCRoasterCell.h"
#import "SSFilter.h"
#import "SSSecurityVC.h"
#import "SSProfileVC.h"
#import "SSApp.h"

@interface SSSearchVC ()
{
    IBOutlet UISearchBar *searchBar;
    IBOutlet UIView *searchBarView;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *pulldownHandle;
    float searchbarWidth;
    UIBarButtonItem *search;
    NSArray *rightBarButtonItems;
}

@end

@implementation SSSearchVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
        self.orderBy = UPDATED_AT;
        self.ascending = YES;
        self.limit = 20;
        self.tabBarItem.image = [UIImage imageNamed:@"06-magnify"];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    if(self.addable)
    {    search.imageInsets = UIEdgeInsetsMake(2.0,-35.0, 0, 5);
        self.navigationItem.rightBarButtonItems = [self addBarItem: self.navigationItem.rightBarButtonItem to:search];
    }
    else{
        self.navigationItem.rightBarButtonItem = search;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    searchBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    searchBar.translucent = self.navigationController.navigationBar.translucent;
    searchBar.barStyle = self.navigationController.navigationBar.barStyle;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    pulldownHandle.hidden = !self.filterable;
   
    rightBarButtonItems = self.navigationItem.rightBarButtonItems;
}

- (void) showSearch:(id) sender
{
    int offset = 50;

    
    [UIView animateWithDuration:0.5 animations:^{
        self.navigationItem.titleView = searchBarView;
        self.navigationItem.rightBarButtonItems = nil;
        
        searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y,
                                     self.view.frame.size.width - btnCancel.frame.size.width - offset, searchBar.frame.size.height);
        btnCancel.hidden = NO;
    }
     ];
    
}

- (IBAction)cancelSearch:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        searchBar.text = nil;
        self.queryPrefix = nil;
        searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, searchbarWidth, searchBar.frame.size.height);
        btnCancel.hidden = YES;
        [searchBar resignFirstResponder];
        self.navigationItem.titleView = nil;
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar                   // called when text starts editing
{
    int offset = 50;

    [UIView animateWithDuration:0.5 animations:^{
        theSearchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y,
                                        self.view.frame.size.width - btnCancel.frame.size.width - offset, searchBar.frame.size.height);
        btnCancel.hidden = NO;
    }
     ];
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

@end
