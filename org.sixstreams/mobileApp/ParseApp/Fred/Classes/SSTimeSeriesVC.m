//
//  SSTimeSeriesVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSTimeSeriesVC.h"
#import "SSTimeSeriesGraphVC.h"

@interface SSTimeSeriesVC ()
{
    NSMutableDictionary *semanticCategories;
    IBOutlet UIViewController *groupByVC;
    IBOutlet UITextField *groupBy;
    
}
- (IBAction)groupBy:(id)sender;

@end

@implementation SSTimeSeriesVC

static NSString  *fredCatSeri = @"http://api.stlouisfed.org/fred/category/series?api_key=ef673da26430e206a8b7d3ce658b7162&file_type=json";

- (NSString *) getUrl:(NSString *)catId
{
    return [NSString stringWithFormat:@"%@&category_id=%@", fredCatSeri, catId ];
}

- (void) showGroup:(id) sender
{
    [self showPopup:groupByVC sender:sender];
}


- (IBAction)groupBy:(id)sender
{
    [self showAlert:groupBy.text withTitle:@"Group By"];
    /*
     NSArray *titleComps = [title componentsSeparatedByString:@" "];
     id semanticCategory = nil;
     NSString *compKey = nil;
     
     for(NSString *comp in titleComps)
     {
     compKey = [NSString stringWithFormat:@"%@%@",compKey ? compKey : @"", comp];
     semanticCategory = [semanticCategories objectForKey:compKey];
     
     if (!semanticCategory)
     {
     semanticCategory = [NSMutableDictionary dictionary];
     [semanticCategories setObject:semanticCategory forKey:compKey];
     }
     [semanticCategory setObject:cat forKey:compKey];
     }
     */
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Group"
                                   style: UIBarButtonItemStylePlain
                                   target: self action: @selector(showGroup:)];
    self.navigationItem.rightBarButtonItem = backButton;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData:self.categoryId];
}

- (void) didFinishLoading: (NSData *)data
{
    id dic = [data toDictionary];
    NSMutableDictionary *categories = [NSMutableDictionary dictionary];
    semanticCategories = [NSMutableDictionary dictionary];
    
    NSArray * cats = [dic objectForKey:@"seriess"];
    if ([cats count]==0)
    {
        return;
    }
    
    for (id cat in cats)
    {
        NSString *title = [cat objectForKey:@"title"];
        [categories setObject:cat forKey:title];
    }
    
    self.data = categories;
    
    [tvCategory reloadData];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedKey = [sortedKeys objectAtIndex:indexPath.row];
    
    id series = [self.data objectForKey: selectedKey];

    if (![self isIPad])
    {
        [self.detailVC loadDataFor:series withBlock:^(NSError *error, id data) {
            [self.navigationController pushViewController:self.detailVC animated:YES];
        }];
    }
    else
    {
        
        [self.detailVC loadDataFor:series withBlock:^(NSError *error, id data) {
            [self.detailVC updateUI];
        }];
    }
    
    
}


@end
