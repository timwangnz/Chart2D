//
//  SSGraphsVC.m
//  SixStreams
//
//  Created by Anping Wang on 2/1/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSBooksVC.h"
#import "SSBookEditorVC.h"
#import "SSProfileEditorVC.h"
#import "SSProfileVC.h"
#import "SSImageView.h"
#import "SSBook.h"
#import "SSTableViewCell.h"
#import "SSGraph.h"
#import "SSStorageManager.h"


@interface SSBooksVC ()<SSEntityEditorDelegate>
{
    SSBook *selected;
    NSMutableArray *books;
    NSMutableArray *localBooks;
}

@end

@implementation SSBooksVC

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = BOOK_CLASS;
    //self.tableColumns = 1;
    self.title = @"Books";
    self.tabBarItem.image = [UIImage imageNamed:@"book.png"];
    self.addable = YES;
    self.editable = YES;
    
    self.queryPrefixKey = TITLE;
    self.orderBy = DATE_FROM;
    self.ascending = NO;
    localBooks = [NSMutableArray array];
}

- (void) graphView:(id)graphView didPerform:(NSString *)cmd
{
    if ([cmd isEqualToString:@"save"])
    {
        [self forceRefresh];
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.objects objectAtIndex:indexPath.row];
    StorageOption storageOption = [[object objectForKey:STORAGE] intValue];
    if (storageOption == localStorage)
    {
        [self.objects removeObject:object];
        NSString *objectId = [object objectForKey:REF_ID_NAME];
        SSBook *bookToDelete = nil;
        for (SSBook *book in localBooks) {
            if ([book.objectId isEqualToString:objectId])
            {
                bookToDelete = book;
                break;
            }
        }
        [localBooks removeObject:bookToDelete];
        [self saveLocally];
        [self refreshUI];
    }
    else
    {
        SSBook *book = [books objectAtIndex:indexPath.row];
        [book deleteOnSuccess:^(id data) {
            [self forceRefresh];
        } onFailure:^(NSError *error) {
            [self showAlert:@"Failed to delete" withTitle:@"Error"];
        }];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void) onDataReceived:(id)objects
{
    [super onDataReceived:objects];
    [self loadLocally];
    books = [NSMutableArray arrayWithCapacity:[objects count]];
    for(id object in objects)
    {
        [books addObject:[[SSBook alloc]initWithData:object]];
    }
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#define CELL @"SSTableViewCellIdentifier"

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSTableViewCell *cell = (SSTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SSTableViewCell" owner:self options:nil];
        cell = (SSTableViewCell *)[nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        //cell.textLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
    }
    
    id item = [self.objects objectAtIndex:indexPath.row];
    cell.title.text = [item objectForKey:NAME];
    cell.subtitle.text = [item objectForKey:CATEGORY];
    cell.author.text = [item objectForKey:USERNAME];
    
    
    cell.icon.defaultImg = [UIImage imageNamed:PERSON_DEFAULT_ICON];
    
    cell.icon.owner = [item objectForKey:AUTHOR];
    cell.icon.url = [item objectForKey:AUTHOR];
    
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([books count]==0)
    {
        return NO;
    }
    SSBook  *book  = [books objectAtIndex:indexPath.row];
    return book.storageOption == localStorage || [[SSProfileVC profileId] isEqualToString:book.authorId];
}

- (NSString *) getCellText:(id) rowItem atCol:(int) col
{
    return [rowItem objectForKey:NAME];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSBook *object = [books objectAtIndex:indexPath.row];
    if ([selected isEqual: object] && [[SSProfileVC profileId] isEqualToString:object.authorId])
    {
        [self editObject:[self.objects objectAtIndex:indexPath.row]];
    }
    else
    {
        selected = object;
        if(![self isIPad])
        {
            self.detailVC = [[SSDrawableVC alloc]init];
            self.detailVC.delegate = self;
        }
        else
        {
            [self.detailVC graphWillChange];
        }
        
        self.detailVC.book = selected;
        
        [selected getDetailsOnSucess:^(id data, NSError *error) {
            if (error)
            {
                [self showAlert:@"Failed to get graphs, please try later" withTitle:@"Error"];
                return;
            }
            SSGraph *graph;
            if ([data count] == 0)
            {
                [selected createPageOnSucess:^(id data, NSError *error) {
                    if (error)
                    {
                        [self showAlert:@"Failed to create a new graph, please try later" withTitle:@"Error"];
                        return;
                    }
                    [self.detailVC changeGraph:data];
                    if(![self isIPad])
                    {
                        [self.navigationController pushViewController:self.detailVC animated:YES];
                    }
                }];
            }else
            {
                graph = [object getFirstPage];
                [graph getDetailsOnSuccess:^(id data, NSError *error) {
                    if (error)
                    {
                        [self showAlert:@"Failed to get shapes, please try later" withTitle:@"Error"];
                        return;
                    }
                    [self.detailVC changeGraph:graph];
                    if(![self isIPad])
                    {
                        self.detailVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:self.detailVC animated:YES];
                    }
                }];
            }
        }];
    }
}

- (BOOL) entityEditor:(SSEntityEditorVC *)editor shouldSave:(id)entity
{
    StorageOption storageOption = [[entity objectForKey:STORAGE] intValue];
    if (storageOption == localStorage)
    {
        SSBook *newLocalBook = nil;
        NSString *entityId = [entity objectForKey:REF_ID_NAME];
        NSInteger max = 0;
        for (SSBook *book in localBooks) {
            
            if (book.sequence > max)
            {
                max = book.sequence;
            }
            if ([book.objectId isEqualToString:entityId])
            {
                newLocalBook = book;
                break;
            }
        }
        if (!newLocalBook) {
            newLocalBook = [[SSBook alloc]initWithData:entity];
            newLocalBook.updatedAt = [NSDate date];
            newLocalBook.authorId = [SSProfileVC profileId];
            newLocalBook.authorName = [SSProfileVC name];
            newLocalBook.sequence = max + 1;
            newLocalBook.objectId=[NSString stringWithFormat:@"localbook_%d", (int) newLocalBook.sequence];
            [localBooks addObject:newLocalBook];
            [books addObject:newLocalBook];
            [self.objects addObject:entity];
            [self refreshUI];
        }
        else
        {
            [newLocalBook fromDictionary:entity];
        }
        [self saveLocally];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    SSEntityEditorVC *entityEditor  = [[SSBookEditorVC alloc]init];
    entityEditor.isCreating = item == nil;
    entityEditor.entityEditorDelegate = self;
    entityEditor.itemType = self.objectType;
    [entityEditor updateEntity:item OfType: self.objectType];
    entityEditor.title = item == nil ? @"Create New Book" : @"Edit Book";
    return entityEditor;
}

- (void) loadLocally
{
    NSDictionary *dic = [[SSStorageManager storageManager] read : self.objectType];
    if (dic == nil)
    {
        return;
    }
    NSArray *localBookData = [dic objectForKey:@"books"];
    for (id data in localBookData) {
        [self.objects addObject:data];
    }
}

- (void) saveLocally
{
    NSMutableDictionary *savedDic = [NSMutableDictionary dictionary];
    NSMutableArray *bookData = [NSMutableArray array];
    for (SSBook *book in localBooks)
    {
        [bookData addObject:[book toDictionary]];
    }
    [savedDic setObject:bookData forKey:@"books"];
    [[SSStorageManager storageManager] save:savedDic uri:self.objectType];
}


@end
