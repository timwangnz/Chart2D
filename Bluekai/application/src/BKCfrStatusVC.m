//
//  CfrStatusVC.m
//  BluekaiDemo
//
//  Created by Anping Wang on 4/25/15.
//  Copyright (c) 2015 Oracle. All rights reserved.
//

#import "BKCfrStatusVC.h"

@interface BKCfrStatusVC ()
{
    NSMutableArray *wins;
}
@end

@implementation BKCfrStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sql =  @"select * from (select creation_date, wins, tags from crf_status_view order by creation_date desc) where rownum<32";

    [self getData];
   ;
}

- (void) didFinishLoading: (id)data
{
    
    NSArray *cats = data[@"data"];
    wins = [NSMutableArray arrayWithArray:cats];
    [tableview reloadData];
}



- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [wins count];
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
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"simpelCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
         ;
        cell.indentationLevel = 0;
    }
    id category = wins[indexPath.row];
    cell.detailTextLabel.text = category[@"CREATION_DATE"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld wins, %ld tags", [category[@"WINS"] longValue], [category[@"TAGS"] longValue]];
    return cell;
}


@end
