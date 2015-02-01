//
//  SSListValueField.m
//  SixStreams
//
//  Created by Anping Wang on 4/5/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSListValueField.h"
@interface SSListValueField()


@end

@implementation SSListValueField

- (NSString *) displayValueFor:(id) item
{
    return [item objectForKey:@"displayValue"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.dataSource = self;
    self.delegate = self;
    self.items = [NSMutableArray array];
    return self;
}

- (void) adjustSize
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.tableHeaderView.frame.size.height
                            + [self.items count] * (self.cellHeight == 0 ? 44 : self.cellHeight));
    //DebugLog(@"%d %d %f", [self.items count], self.cellHeight,self.frame.size.height);
    
}
- (IBAction) addNew:(id)sender
{
    NSMutableDictionary *newItem = [self createItem];
    if (newItem)
    {
        [self editItem:newItem];
    }
}

- (void) setEditable:(BOOL)editable
{
    _editable = editable;
    addBtn.hidden = !_editable;
    [self setUserInteractionEnabled:editable];
}

- (id) createItem
{
    return nil;
}

- (void) setupItems
{
    addBtn.hidden = !self.editable;
    if (_item && _attrName)
    {
        self.items = [NSMutableArray arrayWithArray:[_item objectForKey:_attrName]];
        [_item setObject:self.items forKey:_attrName];
    }
    [self adjustSize];
    [self reloadData];
}

- (void) setItems:(id)items
{
    _items = items;
    [self adjustSize];
}

- (void) setItem:(id) item
{
    _item = item;
    [self setupItems];
}

- (void) setAttrName:(NSString *)attrName
{
    _attrName = attrName;
    [self setupItems];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (void) tableViewCell:(UITableViewCell *) cell forItem:(id) item
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.backgroundColor = self.backgroundColor;
    }
    
    cell.selectionStyle = self.editable ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    id object = [self.items objectAtIndex:indexPath.row];
    
    if ([[object objectForKey:@"selected"] boolValue])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    [self tableViewCell:cell forItem:object];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        id object = [self.items objectAtIndex:indexPath.row];
        [self.items removeObject:object];
        [self adjustSize];
        [self reloadData];
        if(self.fieldDelegate && [self.fieldDelegate respondsToSelector:@selector(listField:didDelete:)])
        {
            [self.fieldDelegate listField:self didDelete:object];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (SSEntityEditorVC *) createEditor
{
    return nil;
}

- (void) entityEditor:(SSEntityEditorVC *)editor didSave:(id)entity
{
    [self reloadData];
    if (![self.items containsObject:entity]) {
        [self.items addObject:entity];
    }
    if(self.fieldDelegate && [self.fieldDelegate respondsToSelector:@selector(listField:didUpdate:)])
    {
        [self.fieldDelegate listField:self didUpdate:entity];
    }
    [self reloadData];
}
- (void) editItem:(id) item
{
    if (self.editable)
    {
        SSEntityEditorVC *expVC = [self createEditor];
        if(expVC)
        {
            expVC.entityEditorDelegate = self;
            expVC.item2Edit = item;
            expVC.readonly = NO;
            [self.parentVC showPopup:expVC sender:self];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.allowCheck)
    {
        id item = [self.items objectAtIndex:indexPath.row];
        BOOL selected = [[item objectForKey:@"selected"] boolValue];
        [item setObject:[NSNumber numberWithBool:!selected] forKey:@"selected"];
        [tableView reloadData];
        return;
        
    }
    [self editItem:[self.items objectAtIndex:indexPath.row]];
}


@end
