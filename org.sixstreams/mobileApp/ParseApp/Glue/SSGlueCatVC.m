//
//  SSGlueCatVC.m
//  SixStreams
//
//  Created by Anping Wang on 1/20/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSGlueCatVC.h"
#import "SSMeetupEditorVC.h"

@interface SSGlueCatVC ()
{
    IBOutlet UITableView *tvCategories;
}

@property (nonatomic, retain) NSString *parentKey;
@property NSInteger parentIndex;
@end

@implementation SSGlueCatVC

static NSDictionary *categoryTree;
static NSArray *services;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.parentKey = nil;
        self.title = @"Select Service";
        self.categories = [SSGlueCatVC services];
    }
    return self;
}

+ (NSArray *) services
{
    if (!services)
    {
        services = [NSArray arrayWithObjects:@"Lunch", @"Service", @"School", @"Social", nil] ;
        categoryTree = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSArray arrayWithObjects:@"Lectures",@"Faculty",@"Chat",@"Gathering", nil],
                        @"Lunch",
                        [NSArray arrayWithObjects:@"Parties",@"Sports&Games",@"Traditions",@"Outings&Trips", nil],
                        @"Social",
                        [NSArray arrayWithObjects:@"Underserved Outreach",@"Education",@"Advocacy",@"Environment", nil],
                        @"Service",
                        [NSArray arrayWithObjects:@"Student Organization",@"Mentorship & Shadowing",@"Conferences",@"Study Group", nil],
                        @"School",
                        nil];
    }
    return services;
}

+ (NSDictionary *) categories
{
    return categoryTree;
}

- (void) viewDidLoad
{
    self.readonly=YES;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tvCategories reloadData];
}

#define CELL @"cell"

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 114;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        UIImageView *bgimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 100)];
        bgimage.tag = 1;
        [cell addSubview:bgimage];
    }
    
    NSString *imgName = [NSString stringWithFormat:@"main_0%d", indexPath.row + 1];
    if (self.parentKey) {
        imgName = [NSString stringWithFormat:@"sub0%d_0%d", self.parentIndex + 1, indexPath.row + 1];
    }
    
    UIImageView *bgimage = (UIImageView*) [cell viewWithTag:1];
    bgimage.image = [UIImage imageNamed:imgName];
    cell.textLabel.text = [self.categories objectAtIndex:indexPath.row];
   
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.parentKey)
    {
        SSEntityEditorVC *entityEditor = [[SSMeetupEditorVC alloc]init];
        entityEditor.itemType = self.itemType;
        [self.item2Edit setObject:self.parentKey forKey:SERVICE];
        [self.item2Edit setObject:[self.categories objectAtIndex:indexPath.row] forKey:SUB_CATEGORY];
        [entityEditor updateEntity:self.item2Edit OfType: self.itemType];
        
        entityEditor.title = @"Create Meeting";
        entityEditor.readonly = NO;
        entityEditor.isCreating = YES;
        [self.navigationController pushViewController:entityEditor animated:YES];
        return;
    }
    
    NSString *key = [self.categories objectAtIndex:indexPath.row];
    SSGlueCatVC *subcategory = [[SSGlueCatVC alloc]init];
    subcategory.item2Edit = [NSMutableDictionary dictionary];
    subcategory.itemType = self.itemType;
    subcategory.categories = [categoryTree objectForKey:key];
    subcategory.parentKey = key;
    subcategory.parentIndex = indexPath.row;
    subcategory.title = @"Select Category";
    [self.navigationController pushViewController:subcategory animated:YES];
}


@end
