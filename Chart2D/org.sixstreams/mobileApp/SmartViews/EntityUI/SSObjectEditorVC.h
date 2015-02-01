//
//  CoreEntityVC.h
//  CoreCrm
//
//  Created by Anping Wang on 11/6/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonUtilVC.h"
#import "SSAttrCell.h"
#import "SSClientDataVC.h"
#import "SSAttrDefGroup.h"
@class SSApp;

@interface SSObjectEditorVC : SSClientDataVC<CoreAttrCellDelegate>
{
    IBOutlet UITableView *attrTableView;
}

@property (strong, nonatomic) id entity;
@property (strong, nonatomic) SSApp *app;
@property BOOL editable;

- (SSAttrDefGroup *) addAttrGroup:(NSString *) name ofType:(NSString *) objectType  forObject:item;
- (void) addAddressGroup: (id) item;

- (void) edit : (id) item;
- (void) create;
- (void) delete;
- (void) save;

- (void) assignAttrValues;
- (void) clearAllGroups;

@end
