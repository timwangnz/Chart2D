//
//  SSFredVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSFredVC.h"
#import "HTTPConnector.h"
#import "SSJSONUtil.h"
#import "SSTimeSeriesVC.h"
#import "SSProfileEditorVC.h"

@interface SSFredVC ()
{
    NSString *selectedId;
}
@property BOOL isChild;
@end


@implementation SSFredVC

static NSString  *fredCat = @"http://api.stlouisfed.org/fred/category/children?api_key=ef673da26430e206a8b7d3ce658b7162&file_type=json";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Fred Insights";
        self.data = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"33060",@"Academic Data",
                           @"32991",@"Money, Banking, & Finance",
                           @"32992",@"National Accounts",
                           @"10",@"Population, Employment, & Labor Markets",
                           @"1",@"Production & Business Activity",
                           @"32455",@"Prices",
                           @"32263",@"International Data",
                           @"3008",@"U.S. Regional Data",
                           nil];
    }
    return self;
}
- (void) showProfile
{
    SSProfileEditorVC *pe = [[SSProfileEditorVC alloc]init];
    [pe editMyProfile];
    [self.navigationController pushViewController:pe animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.isChild)
    {
    NSMutableArray *arrBtns = [[NSMutableArray alloc]init];
    
    UIBarButtonItem *addAcc = [[UIBarButtonItem alloc]
                               initWithTitle:@"Profile"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(showProfile)];
    [arrBtns addObject:addAcc];
    
    self.navigationItem.leftBarButtonItems = arrBtns;
    }
}

- (NSString *) getUrl:(NSString *)catId
{
    selectedId = catId;
    return [NSString stringWithFormat:@"%@&category_id=%@", fredCat, catId];
}

- (void) didFinishLoading: (NSData *)data
{
    id dic = [data toDictionary];
    NSMutableDictionary *categories = [NSMutableDictionary dictionary];
    NSArray * cats = [dic objectForKey:@"categories"];
    if ([cats count]==0)
    {
        SSTimeSeriesVC *children = [[SSTimeSeriesVC alloc]init];
        children.categoryId = selectedId;
        children.title = selectedKey;
        children.detailVC = self.detailVC;
        [self.navigationController pushViewController:children animated:YES];
        return;
    }
    
    for (id cat in cats) {
        [categories setObject:[cat objectForKey:@"id"] forKey:[cat objectForKey:@"name"]];
    }
    
    SSFredVC *children = [[SSFredVC alloc]init];
    children.data = categories;
    children.title = selectedKey;
    children.isChild = YES;
    children.detailVC = self.detailVC;
    
    [self.navigationController pushViewController:children animated:YES];
    
}

@end
