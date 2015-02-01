//
//  ConfigurationManager.m
//  FileSync
//
//  Created by Anping Wang on 10/9/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSConfigManager.h"
#import "SSStorageManager.h"
#import "DebugLogger.h"

@implementation SSConfigManager

static SSConfigManager *configMgr;

+ (SSConfigManager *) getConfigMgr
{
    if (!configMgr)
    {
        configMgr = [[SSConfigManager alloc]init];
    }
    return configMgr;
}


- (NSMutableDictionary *) getConfiguration
{
    if (!config)
    {
        config = [[NSMutableDictionary alloc ]initWithDictionary:[[SSStorageManager storageManager] read:_CONFIG_FILE_KEY]];
    }
    return config;
}

- (id) valueForKey : (NSString *)key ofGroup :(NSString *) groupKey
{
    NSMutableDictionary *configuration = [self getConfiguration];
    NSMutableArray *group = [configuration objectForKey:groupKey];
    for (NSMutableDictionary *item in group)
    {
        if ([[item objectForKey:@"name"] isEqualToString:key])
        {
            return [item objectForKey:@"value"];
        }
    }
    return nil;
}

- (void) setValue : (id) value ofType:(NSString *) metaType at:(int) seq isSecret : (BOOL) isSecret for:(NSString *) name ofGroup : (NSString *) groupKey
{
    config = [self getConfiguration];
    
    NSArray *group = [config objectForKey:groupKey];
    NSMutableArray *newGroup = nil;
    
    if (!group)
    {
        newGroup = [[NSMutableArray alloc]init];
    }
    else
    {
        newGroup = [[NSMutableArray alloc]initWithArray:group];
    }
    BOOL found = false;
    for (NSMutableDictionary *item in newGroup)
    {
        if ([[item objectForKey:@"name"] isEqualToString:name])
        {
            [item setObject: value forKey:@"value"];
            found = YES;
        }
    }
    
    if (!found)
    {
        NSMutableDictionary *property = [[NSMutableDictionary alloc]init];
        [property setObject:name forKey:@"name"];
        [property setObject:value forKey:@"value"];
        [property setObject:metaType forKey:@"type"];
        [property setObject:isSecret ? @"Y" : @"N" forKey:@"isSecret"];
        [newGroup addObject:property];
    }
    
    [config setObject:newGroup forKey:groupKey];
}

- (void) setValue : (id) value for:(NSString *) name ofGroup : (NSString *) groupKey
{
    [self setValue:value ofType:@"" at : 0 isSecret:NO for:name ofGroup:groupKey];
}

- (BOOL) isInitialized
{
    NSMutableDictionary *configuration = [self getConfiguration];
    return configuration != nil && [configuration count] != 0;
}

- (void) clear
{
    config = [self getConfiguration];
    [config removeAllObjects ];
    [self save];
}

- (void) save
{
    [[SSStorageManager storageManager]save:config uri:_CONFIG_FILE_KEY];
}

@end
