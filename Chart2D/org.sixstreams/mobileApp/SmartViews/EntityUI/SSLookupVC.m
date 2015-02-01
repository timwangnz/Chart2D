//
//  SSLookupVC.m
//
//  Created by Anping Wang on 5/9/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSLookupVC.h"

@interface SSLookupVC ()
{
    IBOutlet UITextField *txValue;
    IBOutlet UIView *addView;
}
- (IBAction)addValue:(id)sender;
@end

@implementation SSLookupVC

- (void) showAddView
{
    txValue.text = nil;
    addView.hidden = NO;
}

- (IBAction)addValue:(id)sender
{
    addView.hidden = YES;
    [txValue resignFirstResponder];
    //check first
    NSMutableDictionary *item =[NSMutableDictionary dictionary];
    [item setValue:txValue.text forKey:@"value"];
    [item setValue:txValue.text forKey:@"code"];
    [item setValue:self.attrDef.name forKey:@"attrName"];
    [item setValue:self.attrDef.objectType forKey:@"objectType"];
    
    [[SSClient getClient] createObject:item ofType:self.objectType onCallback:^(SSCallbackEvent *event) {
        if (event.error)
        {
            [self showAlert:@"Error" message:@"Failed to add the value"];
        }
        else{
            [self getObjects];
        }
    }];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.objectType = @"org.sixstreams.social.LookupValue";
    if (!self.attrDef.objectType)
    {
        self.queryString = [NSString stringWithFormat:@"type:%@;attrName:%@", self.attrDef.objectType, self.attrDef.name];
    }
    else
    {
        self.queryString = [NSString stringWithFormat:@"attrName:%@", self.attrDef.name];
    }
    
    self.navigationItem.rightBarButtonItem= [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddView)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [[self.dataObjects objectAtIndex:indexPath.row ] objectForKey:@"value"];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id value = [[self.dataObjects objectAtIndex:indexPath.row ] objectForKey:@"value"];
    NSDictionary *selected = [NSDictionary
                              dictionaryWithObjectsAndKeys:
                              value,
                              @"value",
                              value,
                              @"displayValue",
                              nil ];
    
    [self.cellEditor setValueFromLov:selected];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
