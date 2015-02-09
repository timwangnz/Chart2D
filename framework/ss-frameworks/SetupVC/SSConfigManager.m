//
//  ConfigurationManager.m
//
//  Created by Anping Wang on 10/9/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSConfigManager.h"
#import "SSStorageManager.h"
#import "DebugLogger.h"
#import "SSConnection.h"
#import "SSJSONUtil.h"
#import "SSApp.h"
#import "SSSecurityVC.h"

@interface SSConfigManager()
{
    NSMutableDictionary *config;
}
@end


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

- (id) valueForKey : (NSString *)key ofGroup :(NSString *) groupKey
{
    NSMutableArray *group = [config objectForKey:groupKey];
    for (NSMutableDictionary *item in group)
    {
        if ([[item objectForKey:@"name"] isEqualToString:key])
        {
            return [item objectForKey:@"value"];
        }
    }
    return nil;
}

- (id) setValue : (id) value ofType:(NSString *) metaType at:(int) seq isSecret : (BOOL) isSecret for:(NSString *) name ofGroup : (NSString *) groupKey
{
    //config = [self getConfiguration];
    if(!config)
    {
        return nil;
    }
    
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
    return newGroup;
}

- (id) setValue : (id) value for:(NSString *) name ofGroup : (NSString *) groupKey
{
    return [self setValue:value ofType:@"" at : 0 isSecret:NO for:name ofGroup:groupKey];
}

- (BOOL) isInitialized
{
    return config != nil && [config count] != 0;
}

- (SSConfigManager *) clear
{
    if (config)
    {
        [config removeAllObjects ];
        return self;
    }
    else{
        config = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *) getConfigFileName
{
    return [NSString stringWithFormat:@"org_sixstream_configuratoin_%@", [[SSApp instance] name]];
}

- (SSConfigManager *) save
{
    if([SSSecurityVC isSignedIn])
    {
        if(config)
        {
            [[SSConnection connector] replaceFile:[config JSONData]
                                         fileName:[self getConfigFileName]
                                     fileObjectId:[[SSApp instance] name]
                                        onSuccess:^(id data){
                                            //
                                        }
                                        onFailure:^(NSError *error) {
                                            //
                                        }];
        }
    }
    return self;
}

- (NSMutableDictionary *) getConfiguration
{
    return config;
}

- (void) getConfigurationWithBlock:(SuccessCallback) callback;
{
    if (!config)
    {
       [[SSConnection connector] downloadData:[self getConfigFileName]
                                     onSuccess:^(NSData *data) {
            config = [NSMutableDictionary dictionaryWithDictionary: [data toDictionary]];
            callback(config);
        } onFailure:^(NSError *error) {
            config = nil;
            callback(config);
        }];
    }
    else
    {
        callback(config);
    }
}

@end
