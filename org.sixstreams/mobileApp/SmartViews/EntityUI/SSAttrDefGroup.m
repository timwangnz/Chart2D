//
//  SSAttrDefGroup.m
//  SixStreams
//
//  Created by Anping Wang on 5/11/13.
//  Copyright (c) 2013 SixStreams. All rights reserved.
//

#import "SSAttrDefGroup.h"


@implementation SSAttrDefGroup

- (SSAttrDef *) getAttrDef:(NSString *) attrName
{
    for (SSAttrDef *def in self.attrDefs) {
        if ([attrName isEqualToString:def.name])
        {
            return def;
        }
    }
    return nil;
}

- (NSString *) displayName
{
    return [ObjectTypeUtil displayName:self.name ofType:self.objectType];
}

- (SSAttrDef*) addAttrDef:(NSString *) name
                   ofType:(SSDataType) type
              andMetaType:(SSAttrMetaType) metaType
                withValue:(id) defaultValue
{
    SSAttrDef *attr = [[SSAttrDef alloc]initWithName:name ofType:type andMetaType:metaType withValue:defaultValue];
    
    return [self addAttrDef:attr];
}

- (SSAttrDef *) addAttrDef:(SSAttrDef *) attrDef
{
    if (!self.attrDefs)
    {
        self.attrDefs = [NSMutableArray array];
    }
    [self.attrDefs addObject:attrDef];
    attrDef.objectType = self.objectType;
    attrDef.group = self;
    if (self.object && !attrDef.defaultValue && !self.isList && !self.hideHeader)
    {
        attrDef.defaultValue = [self.object objectForKey:attrDef.name];
    }
    return attrDef;
}

- (SSAttrDef*) addAttrDef:(NSString *) name
                        ofType:(SSDataType) type
                   andMetaType:(SSAttrMetaType) metaType
{
    return [self addAttrDef:name ofType:type andMetaType:metaType withValue:nil];
}

- (SSAttrDef*) addAttrDef:(NSString *) name
                        ofType:(SSDataType) type
{
    return [self addAttrDef:name ofType:type andMetaType:SSPlain withValue:nil];
}
@end
