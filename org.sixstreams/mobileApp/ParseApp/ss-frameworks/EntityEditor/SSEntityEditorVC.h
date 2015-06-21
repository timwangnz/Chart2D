//
//  SSEntityEditorVC.h
// Appliatics
//
//  Created by Anping Wang on 10/6/13.
//  Copyright (c) 2013 Oracle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonVC.h"
#import "SSImageEditorVC.h"
#import "SSTableLayoutView.h"
#import "SSCommentsVC.h"
#import "SSImageView.h"
#import "SSFilter.h"

typedef void (^OnCallback)(id data);

@class SSEntityEditorVC;
@class SSTableViewVC;

@protocol SSEntityEditorDelegate <NSObject>
@optional
- (void) entityEditor:(SSEntityEditorVC *) editor didSave : (id) entity;
- (BOOL) entityEditor:(SSEntityEditorVC *) editor shouldSave : (id) entity;

- (void) entityEditor:(SSEntityEditorVC *) editor didAdd : (id) entity;
- (BOOL) entityEditor:(SSEntityEditorVC *) editor shouldAdd : (id) entity;

- (BOOL) entityEditor:(SSEntityEditorVC *) editor canUpdate : (id) entity;
- (BOOL) entityEditor:(SSEntityEditorVC *) editor canDelete : (id) entity;

- (BOOL) entityEditor:(SSEntityEditorVC *) editor shouldCancel : (id) entity;
- (void) entityEditor:(SSEntityEditorVC *) editor didDelete : (id) entity;
- (void) entityEditor:(SSEntityEditorVC *) editor didCancel : (id) entity;
- (BOOL) entityEditor:(SSEntityEditorVC *) editor didFail : (NSError *) error;
//query by example, called when use click on a searchable field
- (BOOL) entityEditor:(SSEntityEditorVC *) editor selectedFilter : (SSFilter *) filter;

//delegate is called when user press apply filters
- (void) entityEditor:(SSEntityEditorVC *) editor applyFilters : (NSArray *) filters;
- (void) clearFilters;

@end

@interface SSEntityEditorVC :SSCommonVC
{
    SSImageEditorVC *imageEditor;
    IBOutlet SSImageView *iconView;
    IBOutlet SSTableLayoutView *layoutTable;
}

@property (nonatomic, strong) id<SSEntityEditorDelegate> entityEditorDelegate;
@property (nonatomic, strong) id item2Edit;
@property (nonatomic, strong) NSString *itemType;

@property BOOL filterMode;
@property (nonatomic, strong) IBOutlet UIView *filtersView;

//View for a group of attributes to be shown in a view
@property (nonatomic, strong) NSMutableArray *attributeViews;

@property BOOL valueChanged;
@property BOOL readonly;
@property BOOL isCreating;
@property BOOL isFollowable;
@property BOOL isAuthor;
@property BOOL isCommentable;
@property (nonatomic, strong) NSString *titleKey;

+ (void) getObjectById:(NSString *) objectId
                ofType:(NSString *) objectType
           onScuccess :(OnCallback) onSuccess;

//persistent method
- (IBAction) edit :(id)sender;

- (IBAction) save;
- (IBAction) cancel;
- (IBAction) deleteAction:(id)sender;
- (BOOL) checkSaveable;
- (void) doSave:(OnCallback)callback;

- (void) deleteItem:(OnCallback) onSuccess;
- (void) updateData:(OnCallback) onSuccess;

//people follow this entity
- (IBAction)follow:(id)sender;
- (IBAction)unfollow : (UIButton *)sender;
- (void) showFollowers:(id) sender;
- (void) showFollowing:(id) sender;
- (IBAction)comment : (id)sender;

//lifecycle methods
- (void) entityDidSave:(id) object;
- (void) entityWillSave:(id) object;
- (BOOL) entityShouldSave:(id) object;
- (void) entitySaveFailed:(NSError *) object;

- (void) uiWillUpdate:(id) object;

- (void) doLayout;

//
- (void) getData:(NSArray *) filters
          ofType:(NSString *) objectType
        callback:(OnCallback) callback;

- (void) saveOnSuccess:(OnCallback) callback;
- (void) saveInternal:(OnCallback)callback;

- (void) updateEntity:(id) entity OfType:(NSString *) entityType;
- (void) updateEntityById:(NSString *) objectId OfType:(NSString *) entityType;

//handle special types
- (UIDatePicker *) pickADateWithTitle:(NSString *)title andMode:(UIDatePickerMode) mode;
- (IBAction) pickImg:(id) sender;
- (IBAction) pickIcon:(id)sender;
- (IBAction) captureVideo:(id)sender;

- (void) doIFollowThisOnCallback:(OnCallback) callback;
- (SSCommentsVC *) getCommentVC;

- (UIButton *) addLayoutButton:(NSString *) title onTap:(SEL)selector;
- (UIView *) addLayoutSectionHeader:(NSString *) title;
- (void) linkEditFields;
- (void) linkEditorFields:(UIView *) childView;
- (BOOL) linkEditField:(UIView *) editField;

//return filter value editor
- (NSArray *) getFilters;
- (IBAction) clearFilters;

//what the heck does this one do
- (void) view:(UIView *) view readonly:(BOOL) ro;
- (void) createEntity:(id) entity OfType:(NSString *) entityType onSuccess:(OnCallback) onSuccess;
- (void) deleteEntity:(NSString*) objectId OfType:(NSString *) entityType onSuccess:(OnCallback) onSuccess;
- (id) value:(id) item attrName:(NSString *) attrName;

//short hand for profile info
- (NSString *) profileId;
- (id) profile;
- (IBAction)showAuthorProfile:(id)sender;

//to be override to creat a search VC
- (SSTableViewVC *) createSearchVC;
- (IBAction) findSimilarObjects:(id)sender;

//update view based if the vc is readonly or not
- (BOOL) updateEditorView:(UIView *) childView;

@end
