//
//  StorageManager.h
//  Sync
//
//  TODO This is protopical implementation
//
//  Created by Anping Wang on 9/19/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSStorageManager : NSObject

+ (SSStorageManager *) storageManager;

- (void) save : (NSDictionary *) dictionary uri :(NSString *) uri;
- (NSDictionary *) read :(NSString *) uri;
- (NSDictionary *) readFromResource :(NSString *) uri;

- (void) saveContent : (NSData *) data uri :(NSString *) uri;
- (NSData *) readContent :(NSString *) uri;
- (void) clearContent : (NSString *) uri;

- (NSString *) getCacheFileName:(NSString *) uri;

- (BOOL) deleteLocalFile:(NSString *) filename;
- (void) clearJson : (NSString *) uri;

- (void) cleanup;

@end
