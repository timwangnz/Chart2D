//
//  SSEntity.h
//  SixStreams
//
//  Created by Anping Wang on 2/11/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSConnection.h"

@interface SSEntityObject : NSObject

typedef enum
{
    created = 0,
    updated,
    deleted,
    saved,
    synched,
    dirty
}
EntityStatus;

typedef enum
{
    localStorage = 0,
    cloudStorage,
    interactiveStorage
}
StorageOption;

@property (nonatomic) NSString *objectId;
@property (nonatomic) NSString *authorId;
@property (nonatomic) NSString *authorName;
@property (nonatomic) NSDate *updatedAt;
@property EntityStatus status;
@property int sequence;

- (id) toDictionary;
- (void) fromDictionary:(NSDictionary *) dic;

- (void) saveOnSuccess: (SuccessCallback) callback
             onFailure: (ErrorCallback) errorCallback;
-(void) deleteOnSuccess: (SuccessCallback) callback
              onFailure: (ErrorCallback) errorCallback;
- (void) save;
- (void) onSaved:(id) data;

- (NSString *) getEntityType;

@end
