//
// AppliaticsInstance.m
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSObject.h"
#import <Parse/Parse.h>
#import "SSProperty.h"
#import "DebugLogger.h"

@interface SSObject ()
{
    NSMutableDictionary *instanceData;
}
@end

@implementation SSObject

- (void) populate:(PFObject *) pfObject
{
    for (NSString *key in [self.definition.properties allKeys])
    {
        SSProperty *object = [self.definition.properties objectForKey:key];
        if (!object)
        {
            object = nil;
        }
        else
        {
            id value = [instanceData valueForKey:object.name];
            if (value)
            {
                [pfObject setObject: value forKey:object.name];
            }
            else
            {
                [pfObject setObject: @"" forKey:object.name];
            }
        }
    }
}

- (void) setPropertyValues:(id) data
{
    instanceData = data;
}

- (SSObject *) setObject:(id)value forKey:(NSString *)key
{
    if (!self.definition)
    {
        DebugLog(@"We dont have definition");
        return self;
    }
    
    id property = [self.definition.properties valueForKey:key];
    
    if (property == [NSNull null] || !property)
    {
        DebugLog(@"We dont have property defined %@", key);
        return self;
    }
    if (!instanceData)
    {
        instanceData = [NSMutableDictionary dictionary];
    }
    
    if (value && key)
    {
        [instanceData setObject: value forKey : key];
    }
    else
    {
        DebugLog(@"Value or key are nil so nothing stored");
    }
    return self;
}

- (BOOL) save
{
    PFObject *testObject = [PFObject objectWithClassName: self.definition.className];
    [self populate:testObject];
    if([testObject save])
    {
        DebugLog(@"Success in saving");
        return YES;
    }
    else
    {
        DebugLog(@"Failed to save");
        return NO;
    }
}

@end
