//
//  SSEntity.m
//  SixStreams
//
//  Created by Anping Wang on 2/11/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSEntityObject.h"
#import "SixStreams.h"
@interface SSEntityObject()
{
    BOOL isUpdating;
    int dbStatus;
}
@end

@implementation SSEntityObject

-(void) saveOnSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    SSConnection *conn = [SSConnection connector];
    isUpdating = YES;
    id obj = [self toDictionary];
    if (obj)
    {
        [conn createObject:obj
                    ofType: [self getEntityType]
                 onSuccess:^(id data)
         {
             isUpdating = NO;
             [self fromDictionary:data];
             callback(data);
         } onFailure:^(NSError *error)
         {
             isUpdating = NO;
             errorCallback(error);
         }];
    }
}

-(void) deleteOnSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    SSConnection *conn = [SSConnection connector];
    isUpdating = YES;
    dbStatus = 1;
    id obj = [self toDictionary];
    if (obj)
    {
        [conn deleteObject:obj ofType:[self getEntityType] onSuccess:^(id data) {
            callback(self);
            isUpdating = NO;
        } onFailure:^(NSError *error) {
            errorCallback(error);
            isUpdating = NO;
        }];
    }
}

- (void) fromDictionary:(NSDictionary *) dic
{
    if(dic == nil)
    {
        return;
    }
    self.objectId = [dic objectForKey:REF_ID_NAME];
    self.authorId = [dic objectForKey:AUTHOR];
    self.updatedAt = [dic objectForKey:UPDATED_AT];
    self.authorName = [dic objectForKey:USERNAME];
    dbStatus = [[dic objectForKey:STATUS] intValue];
    self.sequence = [[dic objectForKey:SEQUENCE] intValue];
}

- (id) toDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if(self.objectId)
    {
        [dic setObject:self.objectId forKey:REF_ID_NAME];
    }
    if (self.authorId)
    {
        [dic setObject:self.authorId forKey:AUTHOR];
    }
    [dic setValue:self.authorName forKey:USERNAME];
    [dic setObject:[NSNumber numberWithInt:(int)self.sequence] forKey:SEQUENCE];
    [dic setObject:[NSNumber numberWithInt:dbStatus] forKey:STATUS];
    return dic;
}

- (NSString *) getEntityType
{
    return nil;
}

- (void) onSaved:(id)data
{
    //does nothing, override
}

- (void) save
{
    [self saveOnSuccess:^(id data) {
        [self onSaved:data];
        self.status = saved;
    } onFailure:^(NSError *error) {
        self.status = dirty;
    }];
}


@end
