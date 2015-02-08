//
//  CommonSetupEditorVC.h
//  FileSync
//
//  Created by Anping Wang on 10/8/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonVC.h"

@protocol PropertyEditDelegate <NSObject>
- (id) valueToEdit;
- (void) valueDidChange : (id) sender;
- (BOOL) shouldValueChange :(id) sender;
- (void) actionCancelled :(id) sneder;
@end

@interface SSSettingAttributeEditorVC : SSCommonVC
{

}
@property (strong) id propertyEditorDelegate;

@end
