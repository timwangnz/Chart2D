//
//  SSGroupVC.m
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSGroupVC.h"
#import "SSGroupEditorVC.h"
#import "SSImageView.h"
#import <Parse/Parse.h>
#import "SSProfileVC.h"
#import "SSMembershipVC.h"
#import "SSApp.h"

@interface SSGroupVC ()<SSTableViewVCDelegate>
{
    IBOutlet UIView *menuView;
}

@end

@implementation SSGroupVC

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.titleKey = GROUP_NAME;
    self.objectType = GROUP_CLASS;
    self.iconKey = GROUP_ID;
    self.editable = NO;
    self.addable = YES;
    cellMargin = 5;
    self.title = @"My Groups";
    [self.predicates addObject:[SSFilter on:PRIVACY op:EQ value:[NSNumber numberWithInt:0]]];
    self.editable = NO;
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    SSGroupEditorVC *entityEditor = [[SSGroupEditorVC alloc]init];
    
    entityEditor.title = @"GLUE";
    entityEditor.readonly = item ? YES : NO;
    entityEditor.isCreating = item == nil;
    entityEditor.itemType = self.objectType;
    entityEditor.item2Edit  = item;
    return entityEditor;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger num = [self.objects count];
    if (num % 2)
        return [self.objects count]/2 + 1;
    else
        return [self.objects count]/2;
}

#define CELL @"cell"

- (UIImageView *) imageForCell:(UITableViewCell *) cell row:(NSUInteger) row col:(NSUInteger) col
{
    if (!self.iconKey) {
        return nil;
    }
    
    id item  = [self.objects objectAtIndex:row*2+col];
    
    SSImageView *imageView = [[SSImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.cornerRadius = 2;
    if (self.defaultIconImgName)
    {
        imageView.image = [UIImage imageNamed:self.defaultIconImgName];
    }
    imageView.owner = [item objectForKey:AUTHOR];
    imageView.url = [item objectForKey:REF_ID_NAME];
    return imageView;
}


- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(NSUInteger) row
{
    int height = self.defaultHeight;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,0,cell.frame.size.width, height)];
    
    view.backgroundColor = [UIColor clearColor];
    UIView *view1 = [self tableView: tableView cell:cell row:row col:0];
    UIView *view2 = [self tableView: tableView cell:cell row:row col:1];
    
    [view addSubview:view1];
    if (view2)
    {
        view2.frame = CGRectMake(height + cellMargin, cellMargin, height - 2 * cellMargin,height - 2 * cellMargin);
        [view addSubview:view2];
    }
    return view;
}

- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(NSUInteger) row col:(NSUInteger) col
{
    int height = self.defaultHeight;
    
    if(row * 2 +  col > [self.objects count] - 1)
    {
        return nil;
    }
    
    UIImageView *imageView = [self imageForCell:cell row:row col:col];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0,height - 2 * cellMargin, height - 2 * cellMargin)];
    
    imageView.frame = CGRectMake(0, 0, height - 2 * cellMargin, height - 2 * cellMargin);
    
    [view addSubview:imageView];
    
    UIButton *textView = [[UIButton alloc]initWithFrame:imageView.frame];
    
    textView.tag = row * 2 +  col;
    
    id item = self.objects[textView.tag];
    
    [textView addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
    textView.alpha = 0.5;
    textView.backgroundColor = [UIColor blackColor];
    
    imageView.frame = view.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    [view addSubview:textView];
    [view bringSubviewToFront:textView];
    
    NSString *cellText = item[NAME];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, height/2 - 20, textView.frame.size.width- 20, 48)];
    label.text  = cellText;
    label.center = view.center;
    label.numberOfLines = 2;
    
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    view.frame = CGRectMake(cellMargin, cellMargin, height - 2 * cellMargin, height - 2 *cellMargin);
    return view;
}

- (void) didSelect:(UIButton *) sender
{
    id item = self.objects[sender.tag];
    [self onSelect:item];
    [dataView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//do nothing

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        int height = self.defaultHeight == 0 ? tableView.rowHeight : self.defaultHeight;
        cell.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
    cell.textLabel.text = @"";
    UIView *cellFrame = [self tableView:tableView cell:cell row:indexPath.row];
    [cell.contentView addSubview: cellFrame];
    return cell;
}

@end
