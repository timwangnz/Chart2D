//
//  ConfigurationManager.h
//  FileSync
//
//  Created by Anping Wang on 10/9/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>

#define _CONFIG_FILE_KEY @"configuration/configFileKey"

@interface SSConfigManager : NSObject
{
    NSMutableDictionary *config;
}


+ (SSConfigManager *) getConfigMgr;

- (NSMutableDictionary *) getConfiguration;

- (id) valueForKey : (NSString *)key ofGroup :(NSString *) group;
- (void) setValue : (id) value ofType:(NSString *) metaType at:(int) seq isSecret : (BOOL) isSecret for:(NSString *) name ofGroup : (NSString *) groupKey;


- (void) setValue : (id) value for:(NSString *) key ofGroup : (NSString *) group;
- (void) save;
- (void) clear;
- (BOOL) isInitialized;


@end
