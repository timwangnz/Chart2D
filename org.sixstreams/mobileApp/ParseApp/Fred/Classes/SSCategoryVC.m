//
//  SSTimeSeriesVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCategoryVC.h"
#import "SSTimeSeriesGraphVC.h"

@interface SSCategoryVC ()
{
    NSMutableDictionary *semanticCategories;
    IBOutlet UIViewController *groupByVC;
    IBOutlet UITextField *groupBy;
    NSMutableArray *selectedKeys;
    
}
- (IBAction)groupBy:(id)sender;

@end

@implementation SSCategoryVC

static NSString  *fredCatSeri = @"http://api.stlouisfed.org/fred/category/series?api_key=ef673da26430e206a8b7d3ce658b7162&file_type=json";

- (void) clearSelections
{
    [selectedKeys removeAllObjects];
    [tvCategory reloadData];
}

- (NSString *) getUrl:(NSString *)catId
{
    return [NSString stringWithFormat:@"%@&category_id=%@", fredCatSeri, catId];
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
    self.detailVC.categoryVC = self;
    [self reloadData: self.categoryId];
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
    
    NSMutableArray *groups = [NSMutableArray array];
    
    id cat = cats[0];
    
    NSString *title = [cat objectForKey:@"title"];
    
    if([groups count]==0)
    {
        NSArray *stringArray = [title componentsSeparatedByString: @" "];
        NSMutableArray *processed = [NSMutableArray array];
        for(int  i = 0; i<[stringArray count];i++)
        {
            [processed addObject: stringArray[i]];
            groups[i] = [processed componentsJoinedByString:@" "];
        }
    }

    
    //NSLog(@"%@", groups);
    for (id cat in cats)
    {
        NSString *title = [cat objectForKey:@"title"];
        /*
        for (NSInteger i = [groups count] - 2; i >= 0; i --) {
            if ([title containsString:groups[i]])
            {
                title = [title substringFromIndex:[groups[i] length]];
                break;
            }
        }
        */
        [categories setObject:cat forKey:title];
    }
    
    selectedKeys = [NSMutableArray array];
    self.data = categories;
    [tvCategory reloadData];
}

#define CELL @"cell"

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    NSString *key = [sortedKeys objectAtIndex:indexPath.row];
    if ([selectedKeys containsObject:key])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[self cellText: [self.data objectForKey:key] forKey:key] display:36 header:8];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id row = [sortedKeys objectAtIndex:indexPath.row];
    if ([selectedKeys containsObject:row])
    {
        id series = [self.data objectForKey: row];
        [self.detailVC removeSeries:series];
        [selectedKeys removeObject:row];
    }
    else
    {
        [selectedKeys addObject:row];
        selectedKey = row;
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
    [tableView reloadData];
}


@end
