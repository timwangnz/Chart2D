//
//  CoreLovVCViewController.m
//  CoreCrm
//
//  Created by Anping Wang on 11/11/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import "SSLovVC.h"
#import "SSAttrCell.h"

@interface SSLovVC ()<UITableViewDelegate, UITableViewDataSource>
{
    NSString *attrName;
    SSAttrCell *editor;
    IBOutlet UITableView *tbListValues;
}

@end

@implementation SSLovVC

- (void) cellEdtior : (SSAttrCell*) cellEditor selectValueFor :(NSString *) lovAttrName
{
    attrName = lovAttrName;
    editor = cellEditor;
    self.title = attrName;
}


- (void) configureCell:(UITableViewCell *)cell entity:(id)entity
{
    cell.textLabel.text = [entity valueForKey:@"displayName"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tbListValues reloadData];
}

#pragma TableView

- (NSInteger) tableView :(UITableView *) tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listOfValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"defaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = [[self.listOfValues allValues] objectAtIndex:indexPath.row];
  //  cell.detailTextLabel.text = [[self.listOfValues allValues] objectAtIndex:indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selected = [NSDictionary
                              dictionaryWithObjectsAndKeys:                              
                              [[self.listOfValues allKeys] objectAtIndex:indexPath.row],
                              @"value",
                              [[self.listOfValues allValues] objectAtIndex:indexPath.row],
                              @"displayValue",
                              nil ];
    
    [editor setValueFromLov:selected];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
