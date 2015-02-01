//
//  SSEntityEditorVC.h
//  Mappuccino
//
//  Created by Anping Wang on 4/9/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSClientDataVC.h"

@interface SSEntityEditorVC : SSClientDataVC
{
    IBOutlet UITableView *attrTableView;
}

@property (strong, nonatomic) NSMutableDictionary * entity;
@property (strong, nonatomic) NSDictionary *selectedValue;
@property (strong, nonatomic) NSString *selectedSection;
@property BOOL editable;

- (NSString *) getDisplayName:(NSString *) attrName;
- (void) setAttrValue:(id) value forAttr:(NSString *)attrName;

@end
