//
//  SSTableViewVC.m
// Appliatics
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import "SSTableViewVC.h"

#import "SSEntityEditorVC.h"
#import "SSTableViewCell.h"
#import "SSStorageManager.h"
#import "SSSecurityVC.h"
#import "SSRoundView.h"
#import "SSApp.h"
#import "SSValueField.h"

@interface SSTableViewVC ()<SSEntityEditorDelegate>
{
    BOOL editting;
    int page;
    BOOL isRefreshing;
    UIView *waitingView;
    
    NSArray *presetFitlers;
    
    SSEntityEditorVC *filtersVC;
}

@end

@implementation SSTableViewVC

+ (SSTableViewVC *) tableViewFor:(NSString *) objectType delegate:(id) delegate
{
    SSTableViewVC *tableView = [[SSTableViewVC alloc] init];
    tableView.objectType = objectType;
    tableView.tableViewDelegate = delegate;
    return tableView;
}

- (void)awakeFromNib
{
    [self setupInitialValues];
    [super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.showBusyIndicator = YES;
        self.limit = 200;
        self.offset = 0;
        iconMargin = 5;
        [self setupInitialValues];
    }
    return self;
}

- (void) waitingView
{
    waitingView = [[UIView alloc]initWithFrame:self.view.bounds];
    waitingView.backgroundColor = [UIColor blackColor];
    waitingView.alpha = 0.1;
    waitingView.tag = 100000;
    
    SSRoundView *roundView = [[SSRoundView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    roundView.center = CGPointMake(self.view.frame.size.width/2, 200);
    roundView.cornerRadius = 12;
    roundView.backgroundColor = [UIColor blackColor];
    roundView.tag = 100001;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(roundView.frame.size.width/2, roundView.frame.size.width/2);
    [roundView addSubview:spinner];
    [spinner startAnimating];
    [self.view addSubview:waitingView];
    [self.view addSubview:roundView];
    
    [self.view bringSubviewToFront:waitingView];
    [self.view bringSubviewToFront:roundView];
}

- (void) doneWaiting
{
    [[self.view viewWithTag:100000] removeFromSuperview];
    [[self.view viewWithTag:100001] removeFromSuperview];
}

- (NSString *) cacheKey
{
    if ([self.predicates count]>0)
    {
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@_%d%d", self.objectType, self.queryPrefix ? self.queryPrefix : @"", (int) self.offset, self.limit];
}

- (void) cacheObjects:(id) objects
{
    [self cacheObject:objects forKey:[self cacheKey]];
}

- (id) cachedObjects
{
    return [self cachedObjectForKey:[self cacheKey]];
}


- (void) cacheObject:(id) object forKey:(NSString *) key
{
    if (object == nil || object == [NSNull null])
    {
        return;
    }
    NSMutableDictionary *cache = [NSMutableDictionary dictionary];
    [cache setObject:object forKey:CACHED_DATA];
    [cache setObject:[NSDate date] forKey:CACHED_AT];
    [[SSStorageManager storageManager] save:cache uri:key];
}

- (NSTimeInterval) cacheDuration
{
    return 300;//30 minutes
}

- (id) cachedObjectForKey:(NSString *) key
{
    if (key == nil)
    {
        return nil;
    }
    id cache =  [[SSStorageManager storageManager] read:key];
    if (!cache)
    {
        return nil;//miss
    }
    id data = [cache objectForKey:CACHED_DATA];
    NSDate *timeCached = [cache objectForKey:CACHED_AT];
    
    if ([[NSDate date] timeIntervalSinceDate: timeCached] < [self cacheDuration])
    {
        return data;
    }
    return nil;
}

- (id) cachedDataForKey:(NSString *) key
{
    NSString *objectType = self.objectType;
    if (!objectType)
    {
        objectType = [NSString stringWithFormat:@"%@", [self class]];
    }
    id cache = [[SSStorageManager storageManager] read:[NSString stringWithFormat:@"%@.%@", objectType, key]];
    if (cache)
    {
        return [cache objectForKey:CACHED_DATA];
    }
    return nil;
}

- (void) setDataView:(id) newDataView
{
    dataView = newDataView;
}

- (void) setupInitialValues
{
    self.limit = 10;
    self.offset = 0;
    self.showBusyIndicator = YES;
    self.predicates = [NSMutableArray array];
}

- (void) deleteObjects:(NSString *)objectType onSuccess:(SuccessCallback)callback onFailure:(ErrorCallback)errorCallback
{
    SSConnection *conn = [SSConnection connector];
    [conn  deleteObjectsWithFilters:self.predicates ofType:objectType onSuccess:^(id data) {
        if (callback)
        {
            callback(data);
        }
    } onFailure:^(NSError *error) {
        errorCallback(error);
    }];
    
}

- (void) deleteObject : (id) object
               ofType : (NSString *) type
{
    if(!type || !object)
    {
        return;
    }
    
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:shouldDelete:)]) {
        if (![self.tableViewDelegate tableViewVC:self shouldDelete:object])
        {
            //delegate override
            return;
        }
    }
    
    SSConnection *synchronizer = [SSConnection connector];
    [synchronizer deleteObject: object
                        ofType:type
                     onSuccess:^(NSDictionary *object)
     {
         if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:didDelete:)]) {
             [self.tableViewDelegate tableViewVC:self didDelete:object];
         }
         [self forceRefresh];
     } onFailure:^(NSError *error) {
         [self processError:error];
         [self forceRefresh];
     }
     ];
}

- (void) refresh
{
    id objects = [self cachedObjects];
    if(!objects || YES)
    {
        [self getRestfulData];
    }
    else
    {
        [self onDataReceived:objects];
        if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:didLoad:)])
        {
            [self.tableViewDelegate tableViewVC:self didLoad :self.objects];
        }
    }
}

- (void) onDataReceived:(id) objects
{
    if (self.offset == 0)
    {
        self.objects = objects;
    }
    else
    {
        self.objects =[NSMutableArray arrayWithArray: [self.objects arrayByAddingObjectsFromArray:objects]];
    }
}

- (void) nextPage
{
    if (isRefreshing) {
        return;
    }
    self.offset = [self.objects count];
    [self refresh];
    page++;
}

- (void) getRestfulData
{
    selectedPath = nil;
    isRefreshing = YES;
    [self refreshOnSuccess:^(id data) {
        id objects = [data objectForKey:PAYLOAD];
        [self cacheObjects:objects];
        [self refreshUI];
        isRefreshing = NO;
    } onFailure:^(NSError *error) {
        [self processError:error];
        isRefreshing = NO;
    }];
}

- (void) getObject:(NSString*) objectId
        objectType: (NSString *) objectType
         OnSuccess: (SuccessCallback) callback
         onFailure: (ErrorCallback) errorCallback
{
    SSConnection *syncher = [SSConnection connector];
    [syncher objectForKey:objectId ofType:objectType
                 onSuccess:^(id data) {
                     callback(data);
                 } onFailure:^(NSError *error) {
                     errorCallback(error);
                 }];
    
}

- (void) deleleteOnSuccess: (SuccessCallback) callback
                onFailure: (ErrorCallback) errorCallback
{
    selectedPath = nil;
    
    SSConnection *syncher = [SSConnection connector];
    if (self.showBusyIndicator)
    {
        [self waitingView];
    }
    self.queryPrefixKey = self.queryPrefixKey ? self.queryPrefixKey : SEARCHABLE_WORDS;
    [syncher objectsWithPrefix:self.queryPrefix
                         onKey:self.queryPrefixKey
                       filters:self.predicates
                        ofType:self.objectType
                       orderBy:self.orderBy
                     ascending:self.ascending
                        offset:self.offset
                         limit:self.limit
                     onSuccess:^(NSDictionary *data) {
                         [self onDataReceived:[data objectForKey:PAYLOAD]];
                         if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:didLoad:)])
                         {
                             [self.tableViewDelegate tableViewVC:self didLoad :self.objects];
                         }
                         if (callback)
                         {
                             callback(data);
                         }
                         if (self.showBusyIndicator) {
                             [self doneWaiting];
                         }
                     } onFailure:^(NSError *error) {
                         if (self.showBusyIndicator) {
                             [self doneWaiting];
                         }
                         if (errorCallback)
                         {
                             errorCallback(error);
                         }
                     }];
    
}

- (void) refreshAndWait: (SuccessCallback) callback
              onFailure: (ErrorCallback) errorCallback
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSOperation *operation;
    
    operation = [NSBlockOperation blockOperationWithBlock:^{
        SSConnection *syncher = [SSConnection connector];
        
        if (self.showBusyIndicator)
        {
            [self waitingView];
        }
        
        syncher.timeout = 5000;
        
        self.queryPrefixKey = self.queryPrefixKey ? self.queryPrefixKey : SEARCHABLE_WORDS;
        [syncher objectsWithPrefix:self.queryPrefix
                             onKey:self.queryPrefixKey
                           filters:self.predicates
                            ofType:self.objectType
                           orderBy:self.orderBy
                         ascending:self.ascending
                            offset:self.offset
                             limit:self.limit
                         onSuccess:^(NSDictionary *data) {
                             [self onDataReceived:[data objectForKey:PAYLOAD]];
                             if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:didLoad:)])
                             {
                                 [self.tableViewDelegate tableViewVC:self didLoad :self.objects];
                             }
                             if (callback)
                             {
                                 callback(data);
                             }
                             if (self.showBusyIndicator) {
                                 [self doneWaiting];
                             }
                         } onFailure:^(NSError *error) {
                             if (self.showBusyIndicator) {
                                 [self doneWaiting];
                             }
                             if (errorCallback)
                             {
                                 errorCallback(error);
                             }
                         }];

    }];
    
    [queue addOperation:operation];
    [queue waitUntilAllOperationsAreFinished];
    }

- (void) refreshOnSuccess: (SuccessCallback) callback
               onFailure: (ErrorCallback) errorCallback
{
    selectedPath = nil;
    
    SSConnection *syncher = [SSConnection connector];
    if (self.showBusyIndicator)
    {
        [self waitingView];
    }
    self.queryPrefixKey = self.queryPrefixKey ? self.queryPrefixKey : SEARCHABLE_WORDS;
    [syncher objectsWithPrefix:self.queryPrefix
                         onKey:self.queryPrefixKey
                       filters:self.predicates
                        ofType:self.objectType
                       orderBy:self.orderBy
                     ascending:self.ascending
                        offset:self.offset
                         limit:self.limit
                     onSuccess:^(NSDictionary *data) {
                         if (self.showBusyIndicator) {
                             [self doneWaiting];
                         }
                         [self onDataReceived:[data objectForKey:PAYLOAD]];
                         
                         if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:didLoad:)])
                         {
                             [self.tableViewDelegate tableViewVC:self didLoad :self.objects];
                         }
                         if (callback)
                         {
                             callback(data);
                         }

                     } onFailure:^(NSError *error) {
                         if (self.showBusyIndicator) {
                             [self doneWaiting];
                         }
                         if (errorCallback)
                         {
                             errorCallback(error);
                         }
                     }];
}

- (void) saveAllOnSuccess: (SuccessCallback) callback
                          onFailure: (ErrorCallback) errorCallback
{
    [[SSConnection connector] saveAll:self.objects type:self.objectType onSuccess:^(id data) {
        callback(data);
    } onFailure:^(NSError *error) {
        errorCallback(error);
    }];
}

- (void) forceRefresh
{
    page = 0;
    self.offset = 0;
    [self getRestfulData];
}

- (void) refreshUI
{
    dataView.hidden = NO;
    [dataView reloadData];
    if (selectedPath)
    {
        [dataView selectRowAtIndexPath:selectedPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (IBAction) cancel
{
    if(self.navigationController && self.navigationController.visibleViewController != self)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if (self.navigationController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                //
            }];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
        
    }
}

- (void) processError:(NSError *) error
{
    DebugLog(@"%@", error);
}

#pragma tableview
- (void) editTable:(id) sender
{
    if ([dataView isEditing])
    {
        [dataView setEditing:NO animated:YES];
        [((UIBarButtonItem *)sender) setTitle:@"Edit"];
    }
    else
    {
        [dataView setEditing:YES animated:YES];
        [((UIBarButtonItem *)sender) setTitle:@"Cancel"];
    }
}

- (NSString *)tableView:(UITableView *)tableView cellText:(id) rowItem// atCol:(int) col
{
    return self.titleKey ? [[SSApp instance] evaluate:self.titleKey on:rowItem]: @"No Value";
}

- (UIImageView *) imageForCell:(UITableViewCell *) cell row:(NSUInteger) row// col:(int) col
{
    
    id item  = [self.objects objectAtIndex:row];
    
    if (!self.iconKey && !item[PICTURE_URL]) {
        return nil;
    }
    
   
    
    SSImageView *imageView = [[SSImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.cornerRadius = 2;
    
    if (self.defaultIconImgName)
    {
        imageView.defaultImg = [UIImage imageNamed:self.defaultIconImgName];
    }
    
    imageView.owner = [item objectForKey:AUTHOR];
    if(item[PICTURE_URL])
    {
        imageView.url = item[PICTURE_URL];
    }
    else
    {
        imageView.url = [item objectForKey:self.iconKey];
    }
    return imageView;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self deleteObject : [self.objects objectAtIndex:indexPath.row] ofType : self.objectType];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC: heightForRow:)])
    {
        return [self.tableViewDelegate tableViewVC:self heightForRow:indexPath.row];
    }
    return self.defaultHeight == 0 ? tableView.rowHeight : self.defaultHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objects count];
}

- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(NSUInteger) row
{
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:cell:row:)])
    {
        return [self.tableViewDelegate tableViewVC:self cell:cell row:row];
    }
    
    id item  = [self.objects objectAtIndex:row];
    int height = self.defaultHeight == 0 ? tableView.rowHeight : self.defaultHeight;
    int margin = 10;
    
    BOOL asIcon = self.defaultHeight < 200;
    int cellHeight = height;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(cellMargin, 0, cell.frame.size.width - cellMargin * 2, height)];
    
    UIImageView *imageView;
    
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:cellIcon:)])
    {
        imageView = [self.tableViewDelegate tableViewVC:self cellIcon: item];
    }
    else
    {
        imageView = [self imageForCell:cell row:row];
    }
    
    if (imageView)
    {
        if (imageView.frame.size.height == 0 || imageView.frame.size.width == 0)
        {
            imageView.frame = CGRectMake(iconMargin , iconMargin, height - 2*iconMargin, height - 2*iconMargin);
        }
        else
        {
            imageView.frame = CGRectMake(iconMargin , (height - imageView.frame.size.height) / 2, imageView.frame.size.width, imageView.frame.size.height);
        }
        if (!asIcon)
        {
            imageView.frame = view.frame;
        }
        [view addSubview:imageView];
    }
    
    UIView *textView = [[UIView alloc]initWithFrame:CGRectMake(0,0,cell.frame.size.width, height)];
    cell.backgroundColor = [UIColor clearColor];
    
    if (!asIcon)
    {
        imageView.frame = view.frame;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        textView.frame = CGRectMake(margin, 0, view.frame.size.width - 2*margin, cellHeight);
    }
    else
    {
        textView.frame = CGRectMake(imageView.frame.size.width + margin, 0, view.frame.size.width - imageView.frame.size.width - 2*margin, height);
    }
    
    [view addSubview:textView];
    [view bringSubviewToFront:textView];
    
    
    NSString *cellText = nil;
    
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:cellText:)])
    {
        cellText = [self.tableViewDelegate tableViewVC:self cellText: item];
    }
    else
    {
        cellText = [self tableView:tableView cellText:item];
    }
    
    if ([cellText isEqual:[NSNull null]] || !cellText)
    {
        cellText = @"";
    }
    
    if (asIcon)
    {
        NSString *subtitle = self.subtitleKey ? [[SSApp instance] value:item forKey:self.subtitleKey defaultValue:self.subtitleKey] : nil;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(margin, (height - 20) / 2 - (subtitle?14:0), textView.frame.size.width - 2 * margin, 20)];
        label.text  = cellText;
        label.font = [UIFont fontWithName:@"Arial" size:17.0];
        label.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        
        if (selectedPath.row == row)
        {
            label.textColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0];
        }
        
        [textView addSubview:label];
        
        if (subtitle && ![subtitle isEqual:self.subtitleKey])
        {
            label = [[UILabel alloc]initWithFrame:CGRectMake(2 * margin, label.frame.origin.y + label.frame.size.height + 5, textView.frame.size.width - 2 * margin, 20)];
            label.text  = [[SSApp instance] format:subtitle forAttr:self.subtitleKey ofType:self.objectType];
            
            label.font = [UIFont fontWithName:@"Arial" size:14.0];
            label.textColor = [UIColor grayColor];
            [textView addSubview:label];
        }
        else
        {
            textView.frame = CGRectMake(textView.frame.origin.x + 2, (view.frame.size.height - textView.frame.size.height)/2, textView.frame.size.width, textView.frame.size.height);
        }
    }
    else
    {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(margin, height/2 - 30, textView.frame.size.width - 2 * margin, 24)];
        label.text  = cellText;
        label.font = [UIFont boldSystemFontOfSize:24];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [textView addSubview:label];
        
        NSString *subtitle = self.subtitleKey ? [[SSApp instance] value:item forKey:self.subtitleKey] : nil;
        
        if (subtitle && ![subtitle isEqual:self.subtitleKey])
        {
            label = [[UILabel alloc]initWithFrame:CGRectMake(2*margin, label.frame.origin.y + label.frame.size.height + 5, textView.frame.size.width - 2 * margin, 20)];
            label.text  = [[SSApp instance] format:subtitle forAttr:self.subtitleKey ofType:self.objectType];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor grayColor];
            [textView addSubview:label];
        }
        else
        {
            textView.frame = CGRectMake(textView.frame.origin.x + 2, (view.frame.size.height - textView.frame.size.height)/2, textView.frame.size.width, textView.frame.size.height);
        }

    }
    return view;
}

#define CELL @"cell"


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:cellForRowAtIndexPath:tableView:)])
    {
        return [self.tableViewDelegate tableViewVC:self cellForRowAtIndexPath: indexPath tableView:tableView];
    }
    
    NSUInteger row = indexPath.row;
    UITableViewCell *cell = nil;// (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CELL];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.indentationLevel = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:DEFAULT_FONT_SIZE];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        int height = self.defaultHeight == 0 ? tableView.rowHeight : self.defaultHeight;
        cell.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
    }
    
    for (UIView *child in [cell.contentView subviews])
    {
        [child removeFromSuperview];
    }
    
    cell.textLabel.text = @"";
        
    if (self.alterRowBackground && row % 2 == 0)
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];
    }
    else{
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
 
    UIView *cellFrame = [self tableView:tableView cell:cell row:row];
    [cell.contentView addSubview: cellFrame];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedPath = indexPath;
    NSUInteger row = indexPath.row;
    if (row == [self.objects count])
    {
        return;
    }
    [self onSelect:[self.objects objectAtIndex:row]];
    [dataView reloadData];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editable;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id item = [self.objects objectAtIndex:sourceIndexPath.row];
    [self.objects removeObject:item];
    [self.objects insertObject:item atIndex:destinationIndexPath.row];
    int i = 0;
    
    for (item in self.objects)
    {
        [item setObject:[NSNumber numberWithInt:i++] forKey:SEQUENCE];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!self.appendOnScroll)
    {
        return;
    }
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.0) {
        [self nextPage];
    }
}

- (void) onSelectHeader:(id) selected
{
    //no op
}

#pragma Entity related functions

- (IBAction) startEdit:(id)sender
{
    if (!editting)
    {
        [dataView setEditing:YES];
        [dataView beginUpdates];
        if ([sender isKindOfClass:UIBarButtonItem.class])
        {
            ((UIBarButtonItem*)sender).title = @"Save";
        }
        else if([sender isKindOfClass:UIButton.class])
        {
            [sender setTitle:@"Save" forState:UIControlStateNormal];
        }
    }
    else
    {
        [self saveAllOnSuccess:^(id data) {
            [dataView endUpdates];
            [dataView setEditing:NO];
            if ([sender isKindOfClass:UIBarButtonItem.class])
            {
                ((UIBarButtonItem*)sender).title = @"Edit";
            }
            else if([sender isKindOfClass:UIButton.class])
            {
                [sender setTitle:@"Edit" forState:UIControlStateNormal];
            }
            [self forceRefresh];

        } onFailure:^(NSError *error) {
            [self showAlert:@"Failed to save, please try again" withTitle:@"Error"];
        }];
    }
    editting = !editting;
}


- (IBAction) create
{
    [self editObject:nil];
}

- (void) onSelect:(id) selected
{
    if (self.listOfValueDelegate)
    {
        [self hideKeyboard];
        [self.listOfValueDelegate listOfValues:self didSelect:selected];
        if (self.navigationController)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
    else
    {
        if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC: didSelect:)])
        {
            [self.tableViewDelegate tableViewVC:self didSelect:selected];
        }
        else
        {
            [self editObject:selected];
        }
    }
}

-(void) editObject:(id) selected
{
    SSEntityEditorVC *editor = [self createEditorFor:selected];
    if (editor)
    {
        if (!editor.entityEditorDelegate)
        {
            editor.entityEditorDelegate = self;
        }
        
        if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC: showEditor:)])
        {
            [self.tableViewDelegate tableViewVC:self showEditor:editor];
        }
        else
        {
            [editor updateData:^(id data) {
                UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                               initWithTitle: @""
                                               style: UIBarButtonItemStylePlain
                                               target: nil action: nil];
                
                [self.navigationItem setBackBarButtonItem: backButton];
                [self.navigationController pushViewController:editor animated:YES];
            }];
        }
    }
}

- (void) entityEditor:(id)editor didSave:(id)entity
{
    [self forceRefresh];
}

- (void) entityEditor:(id)editor didDelete:(id)entity
{
    [self forceRefresh];
}

- (SSEntityEditorVC *) createEditorFor:(id) item
{
    if (self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableViewVC:createEditor:)])
    {
        return [self.tableViewDelegate tableViewVC:self createEditor:item];
    }
    SSEntityEditorVC *childVC = nil;
    if (self.entityEditorClass)
    {
        Class vcClass = NSClassFromString(self.entityEditorClass);
        childVC = [[vcClass alloc] init];
        if (!childVC)
        {
            NSLog(@"Failed to create VC for %@", self.entityDetailsClass);
            return nil;
        }
    } else
    {
        childVC = [[SSApp instance] entityVCFor:self.objectType];
    }
    
    if(childVC)
    {
        childVC.item2Edit = item;
        childVC.itemType = self.objectType;
        childVC.readonly = item != nil;
        childVC.title = [item objectForKey:self.titleKey];
    }
    return childVC;
}

- (void) setKeyboard:(UISearchBar *) tableSearchBar
{
    for (UIView *searchBarSubview in [tableSearchBar subviews]) {
        
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            
            @try {
                
                [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
            }
            @catch (NSException * e)
            {
                // ignore exception
            }
        }
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self forceRefresh];
    [refreshControl endRefreshing];
}

- (void) setupFiltersView
{
    if (self.filterable)
    {
        filtersVC = [[SSApp instance] entityVCFor:self.objectType];
        if (filtersVC)
        {
            filtersVC.entityEditorDelegate = self;
            [self addChildViewController:filtersVC];
            if (filtersVC.view)
            {
                if (filtersVC.filtersView)
                {
                    filtersVC.view = filtersVC.filtersView;
                    filtersVC.filterMode = YES;
                    filtersVC.view.frame = self.view.bounds;
                    filtersVC.itemType = self.objectType;
                    id saved = [[SSStorageManager storageManager] read:[self cacheFilterKey]];
                    if (saved)
                    {
                        filtersVC.item2Edit = [NSMutableDictionary dictionaryWithDictionary: saved[@"filters"]];
                    }
                    else
                    {
                        filtersVC.item2Edit = [NSMutableDictionary dictionary];
                    }
                    [self.view addSubview:filtersVC.view];
                    [self.view sendSubviewToBack:filtersVC.view];
                }
                else
                {
                    self.filterable = NO;
                }
            }
        }
        else
        {
            self.filterable = NO;
        }
    }
    if (self.predicates)
    {
        presetFitlers = [NSArray arrayWithArray: self.predicates];
    }
}

#pragma vc life cycle
- (void) viewDidLoad
{
    [super viewDidLoad];
    if (self.addable)
    {
        UIBarButtonItem *addAcc = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                   target:self
                                   action:@selector(create)];
        self.navigationItem.rightBarButtonItems = [self addBarItem: addAcc to:self.navigationItem.rightBarButtonItem];
    }
    if (self.editable)
    {
        UIBarButtonItem *editAcc = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self
                                                                   action:@selector(startEdit:)];
        
        self.navigationItem.rightBarButtonItems = [self addBarItem: editAcc to:self.navigationItem.rightBarButtonItem];
    }
    if (self.cancellable)
    {
        UIBarButtonItem *cancelBtn =[[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelBtn;
    }
    
    if (self.pullRefresh) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        [dataView addSubview:refreshControl];
    }
    //setup filters
    [self setupFiltersView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    //[self refreshUI];
}

#pragma filters
#define FILTERS_KEY @"qf"

- (IBAction)applyFilters:(id)sender
{
    NSMutableArray *filters = [NSMutableArray array];
    selectedPath = nil;
    for (SSValueField *editor in [filtersVC getFilters]) {
        if (editor.value)
        {
            if ([editor.value isKindOfClass:[NSArray class]])//multi values
            {
                NSMutableArray *values = [NSMutableArray array];
                for (int i = 0; i<[editor.value count]; i++) {
                    [values addObject:editor.value[i][REF_ID_NAME]];
                }
                if ([values count]>0)
                {
                    [filters addObject:[SSFilter on:editor.attrName op:EQ value:values]];
                }
            }
            else
            {
                if ([editor.attrName isEqualToString:@"nearBy"])
                {
                    [filters addObject:[SSFilter on:editor.attrName op:NEAR_BY value:editor.value]];
                    DebugLog(@"Write location predicate here");
                }
                else
                {
                    [filters addObject:[SSFilter on:editor.attrName op:EQ value:editor.value]];
                }
            }
        }
    }
    
    [[SSStorageManager storageManager] save:@{@"filters": filtersVC.item2Edit, @"time":[NSDate date]} uri:[self cacheFilterKey]];
    
    if (presetFitlers)
    {
        self.predicates = [NSMutableArray arrayWithArray:presetFitlers];
    }
    else
    {
        self.predicates = [NSMutableArray array];
    }
    
    if([filters count]>0)
    {
        [self.predicates addObjectsFromArray:filters];
    }
    
    [self refreshOnSuccess:^(id data) {
        if ([self.objects count] > 0) {
            [self toggleFilters];
        }
        else
        {
            [self showAlert:@"Please change filters" withTitle:@"No results"];
        }
        [self refreshUI];
    } onFailure:^(NSError *error) {
        [self showAlert:@"Please try again later" withTitle:@"Error"];
    }];
    
}

- (void) entityEditor:(SSEntityEditorVC *) editor applyFilters : (NSArray *) filters
{
    [self applyFilters:editor];
}

- (void) clearFilters
{
    [self applyFilters:nil];
}

- (NSString *) cacheFilterKey
{
    if (self.name)
    {
        return [NSString stringWithFormat:@"%@.%@.%@", FILTERS_KEY, self.objectType, self.name];
    }
    else
    {
        return [NSString stringWithFormat:@"%@.%@", FILTERS_KEY, self.objectType];
    }
}

- (IBAction)toggleFilters
{
    [UIView animateWithDuration:0.5 animations:^{
        if (dataView.frame.origin.y > 100)
        {
            dataView.frame = CGRectMake(0, 0,dataView.frame.size.width, dataView.frame.size.height);
        }
        else{
            dataView.frame = CGRectMake(0,dataView.frame.size.height - 80,dataView.frame.size.width, dataView.frame.size.height);
        }
    }];
    
}
@end
