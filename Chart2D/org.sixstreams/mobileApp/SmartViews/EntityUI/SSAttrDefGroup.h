//
//  SSAttrDefGroup.h
//  SixStreams
//
//  Created by Anping Wang on 5/11/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSAttrDef.h"
#import "ObjectTypeUtil.h"

@class SSObjectEditorVC;

@interface SSAttrDefGroup : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *objectType;
@property (strong, nonatomic) id object;
@property (strong, nonatomic) NSMutableArray *attrDefs;

@property BOOL hideHeader;
@property BOOL isAddress;
@property BOOL isActions;
//for list
@property BOOL isList;
@property SSDataType itemDataType;
@property (strong, nonatomic) NSString * itemEditor;

- (NSString *) displayName;

- (SSAttrDef *) getAttrDef:(NSString *) attrName;

- (SSAttrDef *) addAttrDef:(SSAttrDef *) attrDef;

- (SSAttrDef *) addAttrDef:(NSString *) name
                        ofType:(SSDataType) type
                   andMetaType:(SSAttrMetaType) metaType
                     withValue:(id) defaultValue;

- (SSAttrDef *) addAttrDef:(NSString *) name
                        ofType:(SSDataType) type
                   andMetaType:(SSAttrMetaType) metaType;

- (SSAttrDef *) addAttrDef:(NSString *) name
                        ofType:(SSDataType) type;

@end
