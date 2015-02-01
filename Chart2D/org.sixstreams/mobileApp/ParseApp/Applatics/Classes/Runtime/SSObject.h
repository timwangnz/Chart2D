//
// AppliaticsInstance.h
// Appliatics
//
//  Created by Anping Wang on 9/30/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSClassDef.h"

@interface SSObject : NSObject

@property (nonatomic, strong) SSClassDef *definition;

- (SSObject *) setObject:(id)value forKey:(NSString *)key;

- (BOOL) save;
- (void) setPropertyValues:(id) data;

@end
