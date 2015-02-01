//
// AppliaticsObject.m
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//

#import "SSClassDef.h"
#import "SSProperty.h"
#import <Parse/Parse.h>

@interface SSClassDef()
{
    
}


@end

@implementation SSClassDef

+ (SSClassDef *) object :(NSString *) quid
{
    return [[SSClassDef alloc]initWithClass:quid];
}

+ (SSClassDef *) object :(NSString *) quid extends:(SSClassDef *) parentDef
{
    SSClassDef *object = [self object:quid];
    for (NSString *key in [parentDef.properties allKeys]) {
        SSProperty *property = [parentDef.properties objectForKey:key];
        [object addProperty:key property:property];
    }
    return object;
}

- (id) initWithClass:(NSString *) className
{
    self = [super init];
    if (self)
    {
        _className = className;
    }
    return self;
}

- (NSString *) description
{
    NSMutableString *desc = [[NSMutableString alloc]init];
    [desc appendFormat:@"Name : %@ Properites : %@", _className, self.properties ];
    return desc;
}

- (id) addProperty:(NSString *) name property:(SSProperty *) property
{
    if(!self.properties)
    {
        self.properties = [NSMutableDictionary dictionary];
    }
    
    if (![self.properties objectForKey:name])
    {
        [self.properties setObject: property forKey:name];
    }
    else
    {
        //ignore if exists for now
    }
    
    return property;
}


- (id) addProperty:(NSString *) name objectType:(NSString *) type
{
        return [self addProperty:name
                        property:[[SSProperty alloc] initWithName:name
                                                            andType:type]
                ];
}
@end
