//
//  ConfigurationManager.h
//
//  Created by Anping Wang on 10/9/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSConnection.h"

#define _CONFIG_FILE_KEY @"configuration/configFileKey"


@interface SSConfigManager : NSObject


+ (SSConfigManager *) getConfigMgr;

- (void) getConfigurationWithBlock:(SuccessCallback) callback;
- (NSMutableDictionary *) getConfiguration;


- (id) valueForKey : (NSString *)key ofGroup :(NSString *) group;

- (id) setValue : (id) value
         ofType : (NSString *) metaType
             at : (int) seq
       isSecret : (BOOL) isSecret
            for : (NSString *) name
        ofGroup : (NSString *) groupKey;


- (id) setValue : (id) value
            for : (NSString *) key
        ofGroup : (NSString *) group;

- (SSConfigManager *) save;
- (SSConfigManager *) clear;
- (BOOL) isInitialized;

@end
