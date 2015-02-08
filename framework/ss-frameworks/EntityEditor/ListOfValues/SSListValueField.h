//
//  SSListValueField.h
//  SixStreams
//
//  Created by Anping Wang on 4/5/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSEntityEditorVC.h"

/**
 * This is field that contains a list of values 
 @[
 @{},
 @{}
 ]
 **/

@protocol SSListOfValueFieldDelegate <NSObject>
@optional
- (void) listField:(id) listfield didAdd:(id) item;
- (void) listField:(id) listfield didDelete:(id) item;
- (void) listField:(id) listfield didUpdate:(id) item;

@end

@interface SSListValueField : UITableView<UITableViewDelegate, UITableViewDataSource, SSEntityEditorDelegate>
{
    IBOutlet UIButton *addBtn;
}

//if searchable, its values will be made searchable agnainst parent object
@property (nonatomic) BOOL searchable;

@property (nonatomic, retain) SSEntityEditorVC *parentVC;
@property (nonatomic, strong) NSString *attrName;

@property (nonatomic, retain) id<SSListOfValueFieldDelegate> fieldDelegate;

@property (nonatomic, strong) id item;
@property (nonatomic) BOOL editable;
@property (nonatomic, strong) id items;
@property BOOL allowCheck;

@property int cellHeight;

- (void) addNew:(id) sender;

- (NSString *) displayValueFor:(id) item;

@end
