//
//  SSAttrDef.h
//  Mappuccino
//
//  Created by Anping Wang on 5/5/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SSOnAction)(id attrDef);

typedef NS_ENUM(NSInteger, SSDataType) {
    SSDateType,
    SSNumberType,
    SSIntegerType,
    SSStringType,
    SSBooleanType,
    SSActionType,
    SSTextType,
    SSListType,
    SSLovType,
    SSObjectType
};

typedef NS_ENUM(NSInteger, SSAttrMetaType) {
    SSPlain,
    SSEmail,
    SSWebsite,
    SSPhone,
    SSListItemType
};

@class SSAttrDefGroup;

@interface SSAttrDef : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *objectType;
@property (strong, nonatomic) UIColor *backgroundColor;

@property (strong, nonatomic) SSAttrDefGroup * group;

@property (strong, nonatomic) id defaultValue;
@property (strong, nonatomic) id value;
@property (strong, nonatomic) id lov;

@property (strong, nonatomic) SSOnAction onAction;

@property SSDataType dataType;
@property SSAttrMetaType metaType;
@property BOOL hideLabel;

- (id) initWithName:(NSString *) name ofType:(SSDataType) type andMetaType:(SSAttrMetaType) metaType withValue:(id) defaultValue;

- (NSString *) displayValue :(id) value;
- (NSString *) displayName;

@end
