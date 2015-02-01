//
//  SSTableViewVC.h
// Appliatics
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonVC.h"
#import "SSConnection.h"

@class SSEntityEditorVC;

@protocol SSListOfValueDelegate <NSObject>
- (void) listOfValues:(id) tableView didSelect : (id) entity;
@optional
- (BOOL) listOfValues:(id) tableView isSelected:(id) entity;
- (BOOL) multiValueAllowedFor:(id) tableView;
@end

@protocol SSTableViewVCDelegate <NSObject>
@optional
- (SSEntityEditorVC *) tableViewVC:(id) tableViewVC createEditor : (id) entity;
- (void) tableViewVC:(id) tableViewVC showEditor : (SSEntityEditorVC *) editor;
- (void) tableViewVC:(id) tableViewVC hideEditor : (SSEntityEditorVC *) editor;

- (void) tableViewVC:(id) tableViewVC didAdd : (id) entity;

- (void) tableViewVC:(id) tableViewVC didSelect : (id) entity;
- (void) tableViewVC:(id) tableViewVC didDelete : (id) entity;
- (BOOL) tableViewVC:(id) tableViewVC shouldDelete : (id) entity;
- (void) tableViewVC:(id) tableViewVC didLoad : (id) objects;

- (UITableViewCell *) tableViewVC:(id) tableViewVC cellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

- (NSString *) tableViewVC:(id) tableViewVC cellText: (id)rowItem;// atCol:(int) col;
- (UIImageView *) tableViewVC:(id) tableViewVC cellIcon: (id)rowItem;// atCol:(int) col;
- (UIView *) tableViewVC:(id)tableViewVC cell:(UITableViewCell *) cell row:(NSUInteger) row;
- (CGFloat) tableViewVC:(id)tableViewVC heightForRow:(NSInteger) row;

@end

@interface SSTableViewVC : SSCommonVC<UITableViewDataSource, UITableViewDelegate>
{
    NSIndexPath *selectedPath;
    IBOutlet UITableView *dataView;
    int iconMargin;
    int cellMargin;
}

@property (nonatomic, strong) NSString *objectType;

@property (nonatomic) NSString *titleKey;
@property (nonatomic) NSString *subtitleKey;
@property (nonatomic) NSString *iconKey;
@property (nonatomic) NSString *defaultIconImgName;
@property int defaultHeight;


@property (nonatomic, strong) NSString *queryPrefix;
@property (nonatomic, strong) NSString *queryPrefixKey;

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableArray *predicates;
@property (nonatomic, strong) NSString *orderBy;
@property BOOL ascending;

@property BOOL showBusyIndicator;

@property (nonatomic, strong) id<SSListOfValueDelegate> listOfValueDelegate;
@property (nonatomic, strong) id<SSTableViewVCDelegate> tableViewDelegate;
@property SSPrivacy privacy;

@property BOOL cancellable;
@property BOOL addable;
@property BOOL filterable;
@property BOOL editable;

@property BOOL alterRowBackground;
@property int limit;
@property NSInteger offset;

@property BOOL pullRefresh;
@property BOOL appendOnScroll;

@property (nonatomic) NSString *entityEditorClass;
@property (nonatomic) NSString *entityDetailsClass;

- (NSString *)tableView:(UITableView *)tableView cellText:(id) rowItem;
- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(NSUInteger) row;

- (void) setupInitialValues;

- (void) deleteObject:(id) object ofType:(NSString *)objectType;
- (void) deleteObjects:(NSString *)objectType onSuccess:(SuccessCallback)callback onFailure:(ErrorCallback)errorCallback;

- (void) forceRefresh;
- (void) getRestfulData;
- (void) refresh;

- (void) refreshOnSuccess: (SuccessCallback) callback
                onFailure: (ErrorCallback) errorCallback;

- (void) refreshAndWait: (SuccessCallback) callback
                onFailure: (ErrorCallback) errorCallback;

- (void) getObject: (NSString*) objectId
        objectType: (NSString *) objectType
         OnSuccess: (SuccessCallback) callback
         onFailure: (ErrorCallback) errorCallback;

- (void) setDataView:(id) newDataView;
- (void) onDataReceived:(id) objects;

- (void) onSelect:(id) object;

- (void) refreshUI;

- (IBAction) create;
- (IBAction) cancel;
- (IBAction) startEdit:(id)sender;

- (void) editObject:(id) object;

- (SSEntityEditorVC *) createEditorFor:(id) item;

//cache
- (id) cachedObjectForKey:(NSString *) key;
- (id) cachedDataForKey:(NSString *) key;
- (void) cacheObject:(id) object forKey:(NSString *) key;

//filters
- (void) entityEditor:(SSEntityEditorVC *) editor applyFilters : (NSArray *) filters;
- (void) clearFilters;
- (IBAction)toggleFilters;
- (void) setupFiltersView;

@end
