//
// AppliaticsObjectEditorVC.h
// Appliatics
//
//  Created by Anping Wang on 10/2/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSEntityEditorVC.h"
#import "SSDataViewVC.h"

@class SSObjectEditorVC;

@protocol SSObjectEditorDelegate <NSObject>
@optional
- (BOOL) objectEditor:(SSObjectEditorVC *) editor shouldHide : (id) entity;
- (void) objectEditor:(SSObjectEditorVC *) editor didHide : (id) entity;
- (void) objectEditor:(SSObjectEditorVC *)editor panning:(id)entity;
- (void) objectEditor:(SSObjectEditorVC *) editor didSave : (id) entity;
@end
/**
    Object editor is the generic object edit that allows users to edit attributes of an object. It constructs UI from object definition defined
    by the designer.
    This is invoked from a listView
 **/
@interface SSObjectEditorVC : SSEntityEditorVC

@property id<SSObjectEditorDelegate> objectDelegate;
@property SSDataViewVC* dataVC;

+ (SSObjectEditorVC *) objectType:(id) viewDef;

- (void) initUI;
@end
