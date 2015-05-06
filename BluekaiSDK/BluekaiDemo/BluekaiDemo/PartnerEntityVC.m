//
//  PartnerEntityVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/26/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "PartnerEntityVC.h"

@interface PartnerEntityVC ()

@end

@implementation PartnerEntityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.partner count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return  nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
    }
    id key = [self.partner allKeys][indexPath.row];
    cell.textLabel.text = key;
    cell.textLabel.font = [UIFont systemFontOfSize:11];
   
    
    cell.detailTextLabel.text = [self.partner objectForKey:key];
    return cell;
}

@end
