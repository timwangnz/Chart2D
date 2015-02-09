//
//  SSConnection.m
//  Appliatics
//
//  Created by Anping Wang on 9/23/13.
//

#import "SSConnection.h"
#import "SSCacheManager.h"
#import "SSTableViewVC.h"
#import "SSProfileVC.h"
#import "SSFilter.h"
#import <Parse/Parse.h>
#import "SSSecurityVC.h"
#import "SSApp.h"
#import "HTTPConnector.h"

@interface SSConnection ()
{
    BOOL wait;
}


@end

@implementation SSConnection

static NSMutableDictionary *invalidatedObjectTypes;
static NSMutableDictionary *loadedObjectTypes;
static NSMutableDictionary *loadedObjects;
static NSMutableArray *crudListeners;
+ (void) addCrudListener:(id<SSCrudListener>) crudListener
{
    if (crudListeners == nil)
    {
        crudListeners = [NSMutableArray array];
    }
    if (![crudListeners containsObject:crudListener])
    {
        [crudListeners addObject:crudListener];
    }
}
+ (void) removeCrudListener:(id<SSCrudListener>) crudListener
{
    if ([crudListeners containsObject:crudListener])
    {
        [crudListeners removeObject:crudListener];
    }
}

+ (SSConnection *) connector
{
    return [[SSConnection alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
}

- (id)initWithBaseURL: (NSURL *)url
{
    if (!self)
    {
        return nil;
    }
    
    if (invalidatedObjectTypes == nil)
    {
        invalidatedObjectTypes = [NSMutableDictionary dictionary];
        loadedObjectTypes = [NSMutableDictionary dictionary];
        loadedObjects = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void) assignData:(id) data toPfObj:(PFObject *) pfObject
{
    for (NSString *key in [data allKeys])
    {
        if (![key isEqualToString:REF_ID_NAME] && [data objectForKey:key])
        {
            [pfObject setObject:[data objectForKey:key] forKey:key];
        }
    }
        
    if ([PFUser currentUser] && ![data objectForKey:USER_INFO])
    {
        if ([SSProfileVC profileId])
        {
            [pfObject setObject:[SSProfileVC profileId] forKey:AUTHOR];
            [pfObject setObject:[SSProfileVC name] forKey:USER];
            [pfObject setObject:[self userInfo] forKey:USER_INFO];
            [pfObject setValue: [SSProfileVC domainName]forKey:DOMAIN_NAME];
        }
        else
        {
            [pfObject setObject:[PFUser currentUser].objectId forKey:AUTHOR];
            [pfObject setValue: [SSProfileVC domainName]forKey:DOMAIN_NAME];
        }
    }
    
    NSArray *acls = [data objectForKey:ACCESS_CONTROL_LIST];
    PFACL *acl = [[PFACL alloc]init];
    if (acls && [acls count] > 0)
    {
        for (id user in acls)
        {
            NSString *userId = [user objectForKey:USER_ID];
            [acl setWriteAccess:YES forUserId:userId];
            [acl setReadAccess:YES forUserId:userId];
        }
    }
    else
    {
        [acl setPublicReadAccess:YES];
        [acl setPublicWriteAccess:YES];
    }
    
    [pfObject setACL:acl];
}

- (PFObject *) updatePF:(id) data type:(NSString *) objectType
{
    PFObject *pfObject = [self toPFObject:data type:objectType];
    [self assignData:data toPfObj:pfObject];
    return pfObject;
}

- (void) handleCrudEvent:(NSString *) eventType object:(id) data ofType:(NSString*) objectType
{
    [invalidatedObjectTypes setObject:[NSDate date] forKey:objectType];
    for(id<SSCrudListener> listener in crudListeners)
    {
        if ([listener respondsToSelector:@selector(connection:didUpdate:ofType:)] && [eventType isEqualToString:@"update"])
        {
            [listener connection:self didUpdate:data ofType:objectType];
        }
        else if ([listener respondsToSelector:@selector(connection:didDelete:ofType:)] && [eventType isEqualToString:@"delete"])
        {
            [listener connection:self didDelete:data ofType:objectType];
        }
        else if ([listener respondsToSelector:@selector(connection:didGet:ofType:)] && [eventType isEqualToString:@"read"])
        {
            [listener connection:self didGet:data ofType:objectType];
        }
        else if ([listener respondsToSelector:@selector(connection:didCreate:ofType:)] && [eventType isEqualToString:@"create"])
        {
            [listener connection:self didCreate:data ofType:objectType];
        }
    }
}

- (void) updateObject: (NSDictionary *) data
               ofType: (NSString *) objectType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    PFObject *pfObject = [self updatePF:data type:objectType];
    [pfObject setObject:@"YES" forKey:IS_UPDATE];
    [pfObject setObject:[NSDate date] forKey:UPDATED_AT];
    
    [pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            errorCallback(error);
        }
        else
        {
            NSMutableDictionary *response = [NSMutableDictionary dictionary];
            [response setObject:data forKey:PAYLOAD];
            callback(data);
            [self handleCrudEvent:@"update" object:data ofType:objectType];
        }
    }];
}

- (void) saveAll: (NSArray *) items
            type: (NSString *) type
       onSuccess: (SuccessCallback) callback
       onFailure: (ErrorCallback) errorCallback
{
    NSMutableArray *pfObjects = [NSMutableArray array];
    for(id item in items)
    {
        PFObject *pf = [self updatePF:item type:type];
        
        if (pf)
        {
            [pfObjects addObject: pf];
        }
    }
    [PFObject saveAllInBackground:pfObjects
                            block:^(BOOL succeeded, NSError *error) {
                                if (!succeeded)
                                {
                                    errorCallback(error);
                                }
                                else
                                {
                                    callback(nil);
                                }
                            } ];
}

- (void) getChildren : (NSString*) parentId
               forKey: (NSString *) key
               ofType: (NSString *) childType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    [self getChildren:parentId
               forKey:key
               ofType:childType
                since:nil
            onSuccess:callback
            onFailure:errorCallback];
}

- (void) getChildren : (NSString*) parentId
               forKey: (NSString *) key
               ofType: (NSString *) childType
                since: (NSDate *) date
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    if (!childType || !parentId || !key)
    {
        errorCallback([[NSError alloc]initWithDomain:@"arguments are missing" code:201 userInfo:nil]);
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: childType]];
    [query whereKey:key equalTo:parentId];
    
    if (date)
    {
        [query whereKey:UPDATED_AT greaterThan:date];
    }
    
    [query orderByAscending:UPDATED_AT];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            errorCallback(error);
        }
        else
        {
            NSMutableArray *results = [NSMutableArray array];
            for (PFObject *item in objects)
            {
                [results addObject:[self toDictionary:item]];
            }
            callback(results);
        }
    }];
}

- (void) deleteChildren: (NSString*) parentId
                 forKey:(NSString *) key
                 ofType:(NSString *) type
              onSuccess: (SuccessCallback) callback
              onFailure: (ErrorCallback) errorCallback
{
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: type]];
    [query whereKey:key equalTo:parentId];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects) {
                [PFObject deleteAllInBackground:objects
                                          block:^(BOOL succeeded, NSError *error) {
                                              if (succeeded) {
                                                  callback(objects);
                                              }
                                          }];
            }
        }
        
    }];
}

- (void) deleteObjectById: (NSString *) objectId
                   ofType: (NSString *) type
                onSuccess: (SuccessCallback) callback
                onFailure: (ErrorCallback) errorCallback
{
    if (!objectId || !type)
    {
        DebugLog(@"Required arguments are not presented");
        return;
    }
    
    PFObject *pfObject = [self toPFObjectWithId:objectId type:type];
    if (!pfObject)
    {
        return;
    }
    [pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            callback(objectId);
        }
        else
        {
            errorCallback(error);
        }
    }];
}

- (void) deleteObjectById:(NSString *) objectId
               ofType: (NSString *) type
{
    if (!objectId || !type)
    {
        DebugLog(@"Required arguments are not presented");
        return;
    }
    
    PFObject *pfObject = [self toPFObjectWithId:objectId type:type];
    if (!pfObject)
    {
        return;
    }
    NSOperationQueue* myQueue = [[NSOperationQueue alloc] init];
    NSBlockOperation* myOp = [[NSBlockOperation alloc] init];
    [pfObject deleteInBackground];
    [myQueue addOperation:myOp];
    [myQueue waitUntilAllOperationsAreFinished];
    return;
}

- (id) objectForKey: (NSString *) objectId
             ofType: (NSString *) type
{
    if (!objectId || !type)
    {
        DebugLog(@"Required arguments are not presented");
        return nil;
    }
    
    __block id returnObject;
    
    PFObject *pfObject = [loadedObjects objectForKey:objectId];
    if (pfObject)
    {
        return [self toDictionary:pfObject];
    }

    NSString *objectType = [self tableName:type];
    NSOperationQueue* myQueue = [[NSOperationQueue alloc] init];
    NSBlockOperation* myOp = [[NSBlockOperation alloc] init];
    
    [myOp addExecutionBlock:^{
        PFQuery *query = [PFQuery queryWithClassName:objectType];
        returnObject = [query getObjectWithId:objectId];
        [self handleCrudEvent:@"get" object:returnObject ofType:type];
    }];
    [myQueue addOperation:myOp];
    
    [myQueue waitUntilAllOperationsAreFinished];
    
    return [self toDictionary:returnObject];
}

- (void) objectsOfType: (NSString *) type
             authorId: (NSString *) authorId
             onSuccess: (SuccessCallback) callback
             onFailure: (ErrorCallback) errorCallback
{
    if (authorId == nil) {
        return;
    }
    [self objects:[NSPredicate predicateWithFormat:@"ss_author=%@", authorId]
           ofType:type orderBy:CREATED_AT ascending:YES offset:0 limit:100 onSuccess:^(id data) {
               callback(data);
           } onFailure:^(NSError *error) {
               errorCallback(error);
           }];
    
}

- (void) myObjectsOfType: (NSString *) type
               onSuccess: (SuccessCallback) callback
               onFailure: (ErrorCallback) errorCallback
{
    [self objectsOfType:type
               authorId:[SSProfileVC profileId]
              onSuccess:callback
              onFailure:errorCallback];
}

- (void) objectForKey: (NSString *) objectId
               ofType: (NSString *) type
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    if(!objectId || !type)
    {
       errorCallback([[NSError alloc]initWithDomain:@"Required parameters not present" code:5002 userInfo:nil]);
        return;
    }
    
    PFObject *pfObject = [loadedObjects objectForKey:objectId];
    //if (pfObject == nil)
    {
        PFQuery *query = [PFQuery queryWithClassName:[self tableName :type]];
        [query getObjectInBackgroundWithId:objectId block:^(PFObject *pfObject, NSError *error) {
            if(error)
            {
                errorCallback(error);
            }
            else
            {
                id object = [self toDictionary:pfObject];
                callback(object);
                [self handleCrudEvent:@"get" object:object ofType:type];
            }
        }];
        return;
    }
    
    [pfObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error)
        {
            errorCallback(error);
        }
        else{
            callback([self toDictionary:object]);
        }
    }];
}

- (void) toPFObject: (id) data
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback
{
    NSString *objectId = [data objectForKey:REF_ID_NAME];
    if (objectId==nil)
    {
        errorCallback([[NSError alloc]initWithDomain:@"toPFObject requires id" code:1001 userInfo:nil]);
    }
    
    PFObject *pfObject = [loadedObjects objectForKey:objectId];
    
    if (pfObject == nil)
    {
        pfObject = [PFObject objectWithClassName:[self tableName: [data objectForKey:OBJECT_TYPE]]];
    }
    
    [pfObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            errorCallback(error);
        }
        else{
            callback(object);
        }
    }];
}

- (PFObject *) toPFObject:(id) data
                    type :(NSString *)objectType
{
    NSString *objectId = [data objectForKey:REF_ID_NAME];
    
    if(objectId == nil)
    {
        return nil;
    }
    
    return [self toPFObjectWithId:objectId type:objectType];
}

- (PFObject *) toPFObjectWithId:(NSString *) objectId
                    type :(NSString *)objectType
{
    __block id returnObject;
    
    if (objectId==nil)
    {
        return nil;
    }
    
    PFObject *pfObject = [loadedObjects objectForKey:objectId];
    
    if (pfObject != nil)
    {
        return pfObject;
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSOperation *operation;
    
    operation = [NSBlockOperation blockOperationWithBlock:^{
        PFQuery *query = [PFQuery queryWithClassName:[self tableName: objectType ]];
        returnObject = [query getObjectWithId:objectId];
    }];
    
    [queue addOperation:operation];
    [queue waitUntilAllOperationsAreFinished];
    
    return returnObject;
}

- (void) uploadObjects:(NSArray *)objects ofType:(NSString *)objectType
{
    NSMutableArray *newObjects = [NSMutableArray array];
    for (id object in objects)
    {
        [newObjects addObject:[PFObject objectWithClassName: [self tableName: objectType ] dictionary:object]];
    }
    
    [PFObject saveAll:newObjects];
    
}

- (void) createObject: (NSMutableDictionary *) data
               ofType: (NSString *) objectType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    PFObject *pfObject = [self toPFObject:data type:objectType];
    
    if (pfObject)
    {
        [self updateObject: data
                    ofType: objectType
                 onSuccess: callback
                 onFailure: errorCallback];
        return;
    }
    
    if([data objectForKey:CREATED_AT])
    {
        [data removeObjectForKey:CREATED_AT];
    }
    
    PFObject *newObject = [PFObject objectWithClassName:[self tableName: objectType]];
    [self assignData:data toPfObj:newObject];
    
    [newObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded)
        {
            errorCallback(error);
        }
        else
        {
            id newData = [self toDictionary:newObject];
            callback(newData);
            [self handleCrudEvent:@"create" object:newData ofType:objectType];
        }
    }];
}

+ (NSString *) objectType:(NSString *) className
{
    return  [className stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

- (NSString *) tableName:(NSString *) oldName
{
    return  [SSConnection objectType:oldName];
}
//remove values that are used on server only, such as ACL, geopoint etc.
- (void) assign:(PFObject *) pfObject toDic:(NSMutableDictionary *) item
{
    for (id attrKey in [pfObject allKeys])
    {
        if ([attrKey isEqualToString:@"ACL"]) {
            continue;
        }
        
        id obj = [pfObject objectForKey:attrKey];
        if (obj == nil || obj == [NSNull null])
        {
            continue;
        }
        
        if ([obj isKindOfClass:[PFObject class]])
        {
            [item setObject:[self toDictionary:obj] forKey:attrKey];
            
        }
        else if ([obj isKindOfClass:[NSArray class]])
        {
            for(id child in obj)
            {
                if ([child isKindOfClass:[NSDictionary class]])
                {
                    [child removeObjectForKey:@"PFObject"];
                    [child removeObjectForKey:@"ACL"];
                    [child removeObjectForKey:@"ACL"];
                }
            }
            [item setObject:obj forKey:attrKey];
        }
        else if([obj isKindOfClass:[PFFile class]])
        {
            PFFile *file = (PFFile *) obj;
            NSMutableDictionary *fileItem = [NSMutableDictionary dictionary];
            [fileItem setObject:file.url forKey:@"url"];
            [fileItem setObject:file.name forKey:NAME];
            [item setObject:fileItem forKey:attrKey];
        }
        else if([obj isKindOfClass:[PFGeoPoint class]])
        {
            continue;
        }
        else
        {
            [item setObject:obj forKey:attrKey];
        }
    }
    
    [item setValue:pfObject.objectId forKey:REF_ID_NAME];
    [item setValue:pfObject.createdAt forKey:CREATED_AT];
    [item setValue:pfObject.updatedAt forKey:UPDATED_AT];
    if(pfObject.isDataAvailable)
    {
        [loadedObjects setObject:pfObject forKey:pfObject.objectId];
    }
}

- (id) toDictionary:(PFObject *) object
{
    if(object.objectId==nil)
    {
        return nil;
    }
    
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    [self assign:object toDic:item];
    return item;
}

- (void) deleteByFilters: (NSArray *) filters
               ofType: (NSString *) objectType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    
}

- (void) deleteObject: (NSDictionary *) item
               ofType: (NSString *) objectType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback
{
    PFObject *pfObject = [self toPFObject:item type:objectType];
    if (pfObject)
    {
       [pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
           if (!succeeded)
           {
               if(errorCallback)
                   errorCallback(error);
                   else
                   DebugLog(@"Deleted the object");
           }
           else
           {
            
               if (callback)
               {
                   callback(item);
               }
               [self handleCrudEvent:@"delete" object:item ofType:objectType];
           }
        }
       ];
    }
    else
    {
        //should be an error
    }
}

- (NSString *) hashkey: (id) predicate
                ofType: (NSString *) objectType
                offset: (NSUInteger) offset
                 limit: (NSUInteger) limit
{
    NSString *key = [NSString stringWithFormat:@"%@-%d-%d-%@", objectType, (int)offset, (int)limit, predicate];
    return key;
}

- (void) refreshObject: (NSMutableDictionary *) data
                ofType: (NSString *) objectType
             onSuccess: (SuccessCallback) callback
             onFailure: (ErrorCallback) errorCallback
{
    NSString *objectId = [data objectForKey:REF_ID_NAME];
    
    PFObject *pfObject = [loadedObjects objectForKey:objectId];
    
    if (pfObject == nil)
    {
        pfObject = [PFObject objectWithClassName:[self tableName :objectType]];
        pfObject = [pfObject objectForKey:objectId];
    }
    
    [pfObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            errorCallback(error);
        }
        else{
            [self assign:object toDic:data];
            callback(data);
        }
    }];
}

- (void) objectsWithFilters: (NSArray *) filters
                     ofType: (NSString *) objectType
                    orderBy: (NSString *) orderByKey
                  ascending: (BOOL) ascending
                     offset: (NSUInteger) offset
                      limit: (NSUInteger) limit
                  onSuccess: (SuccessCallback) callback
                  onFailure: (ErrorCallback) errorCallback
{
    [self objectsWithPrefix:nil onKey:nil
                    filters:filters
                     ofType:objectType
                    orderBy:orderByKey
                  ascending:ascending
                     offset:offset
                      limit:limit
                  onSuccess:callback
                  onFailure:errorCallback];
}

- (void) pushNotification:(NSString *) msg withFilters: (NSArray *) filters
                   ofType: (NSString *) objectType;
{
    //PFQuery *query = [self queryWithFilters:filters onType:objectType];
}

- (PFQuery *) queryWithFilter: (SSFilter *) filter onType:(NSString *) objectType
{
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: objectType]];
    if ([filter.op isEqualToString:EQ])
    {
        [query whereKey:filter.attrName equalTo:filter.value];
    }
    else if ([filter.op isEqualToString:LESS])
    {
        [query whereKey:filter.attrName lessThan:filter.value];
    }
    else if ([filter.op isEqualToString:GREATER])
    {
        [query whereKey:filter.attrName greaterThan:filter.value];
    }
    else if ([filter.op isEqualToString:PREFIX])
    {
        [query whereKey:filter.attrName hasPrefix:filter.value];
    }
    else if ([filter.op isEqualToString:NE])
    {
        [query whereKey:filter.attrName notEqualTo:filter.value];
    }
    else if ([filter.op isEqualToString:CONTAINS])
    {
        [query whereKey:filter.attrName containedIn:filter.value];
    }
    return query;
}

- (PFQuery *) queryWithFilters: (NSArray *) filters onType:(NSString *) objectType
{
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: objectType]];
    for (SSFilter *filter in filters)
    {
        if ([filter.op isEqualToString:EQ])
        {
            if ([filter.value isKindOfClass:[NSArray class]])
            {
                [query whereKey:filter.attrName containedIn:filter.value];
            }
            else
            {
                [query whereKey:filter.attrName equalTo:filter.value];
            }
        }
        else if ([filter.op isEqualToString:LESS])
        {
            [query whereKey:filter.attrName lessThan:filter.value];
        }
        else if ([filter.op isEqualToString:GREATER])
        {
            [query whereKey:filter.attrName greaterThan:filter.value];
        }
        else if ([filter.op isEqualToString:PREFIX])
        {
            [query whereKey:filter.attrName hasPrefix:filter.value];
        }
        else if ([filter.op isEqualToString:NE])
        {
            [query whereKey:filter.attrName notEqualTo:filter.value];
        }
        else if ([filter.op isEqualToString:CONTAINS])
        {
            [query whereKey:filter.attrName containedIn:filter.value];
        }
        else if ([filter.op isEqualToString:NEAR_BY])
        {
            [query whereKey:filter.attrName nearGeoPoint:[SSProfileVC currentLocation] withinMiles:[filter.value doubleValue]];
        }
        else if ([filter.op isEqualToString:OR_OP])
        {
            NSArray *filters = filter.filters;
            NSMutableArray *queries = [NSMutableArray array];
            for(SSFilter *filter in filters)
            {
                [queries addObject:[self queryWithFilter:filter onType:objectType]];
            }
            query = [PFQuery orQueryWithSubqueries:queries];
        }
        else if ([filter.op isEqualToString:AND_OP])
        {
            NSArray *filters = filter.filters;
            DebugLog(@"%@", filters);
        }
        else
        {
            [query whereKey:filter.attrName equalTo:filter.value];
        }
    }
    return query;
}

- (void) deleteObjectsWithFilters: (NSArray *) filters
                           ofType: (NSString *) objectType
                        onSuccess: (SuccessCallback) callback
                        onFailure: (ErrorCallback) errorCallback
{
    PFQuery *query = [self queryWithFilters:filters onType:objectType];
    query.skip = 0;
    query.limit = 100;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            errorCallback(error);
        }
        else
        {
            for(PFObject *obj in objects)
            {
                [obj deleteInBackground];
            }
            if (callback)
            {
                callback(objects);
            };
        }
    }];
}

- (void) objectsWithPrefix: (NSString *) prefix
                     onKey: (NSString *) key
                   filters: (NSArray *) filters
                    ofType: (NSString *) objectType
                   orderBy: (NSString *) orderByKey
                 ascending: (BOOL) ascending
                    offset: (NSUInteger) offset
                     limit: (NSUInteger) limit
                 onSuccess: (SuccessCallback) callback
                 onFailure: (ErrorCallback) errorCallback
{
    if(!objectType || [objectType length] == 0)
    {
        errorCallback([[NSError alloc]initWithDomain:@"Object type can not be empty" code:5002 userInfo:nil]);
        return;
    }
    
    PFQuery *query = [self queryWithFilters:filters onType:objectType];

    
    if (prefix)
    {
        if (key)
        {
            [query whereKey:key containsAllObjectsInArray: [prefix componentsSeparatedByString:@" "]];
        }
        else
        {
            DebugLog(@"Prefix key is not speicified, query without prefixed value");
        }
    }
    
    NSString *cacheKey = [self hashkey:@"objectsWithPrefix" ofType:objectType offset:offset limit:limit];
    
    id cachedObject = nil;// [self cacheDataForKey:cacheKey ofType:objectType];
    
    if (cachedObject)
    {
        callback(cachedObject);
        return;
    }
    
    query.skip = offset;
    query.limit = limit;
    
    if (orderByKey)
    {
        ascending ? [query orderByAscending:orderByKey] : [query orderByDescending:orderByKey];
    }
    
    if (self.timeout > 0)
    {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_group_async(group, queue, ^ {
            NSArray * objects = [query findObjects];
            NSMutableArray *results = [NSMutableArray array];
            
            for (PFObject *item in objects)
            {
                [results addObject:[self toDictionary:item]];
            }
            
            NSMutableDictionary *response = [NSMutableDictionary dictionary];
            [response setObject:results forKey:PAYLOAD];
            [response setObject:[NSDate date]  forKey:CACHED_AT];
            [self cacheData:results forKey:cacheKey];
            [loadedObjectTypes setObject:[NSDate date] forKey:cacheKey];
            callback(response);
        });
        dispatch_group_wait(group, self.timeout * 1000);
    }
    else
    {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error)
            {
                errorCallback(error);
            }
            else
            {
                NSMutableArray *results = [NSMutableArray array];
                
                for (PFObject *item in objects)
                {
                    [results addObject:[self toDictionary:item]];
                }
                
                NSMutableDictionary *response = [NSMutableDictionary dictionary];
                [response setObject:results forKey:PAYLOAD];
                [response setObject:[NSDate date]  forKey:CACHED_AT];
                [self cacheData:results forKey:cacheKey];
                [loadedObjectTypes setObject:[NSDate date] forKey:cacheKey];
                callback(response);
            }
        }];
    }
}

- (void) objects: (NSPredicate *) predicate
          ofType: (NSString *) objectType
         orderBy: (NSString *) orderByKey
       ascending: (BOOL) ascending
          offset: (int) offset
           limit: (int) limit
       onSuccess: (SuccessCallback) callback
       onFailure: (ErrorCallback) errorCallback
{
    if (!objectType)
    {
        errorCallback([[NSError alloc]initWithDomain:@"ObjectType is required" code:201 userInfo:nil]);
        return;
    }
    
    PFQuery *query;
    
    if (predicate)
    {
        query = [PFQuery queryWithClassName:[self tableName: objectType] predicate:predicate];
    }
    else
    {
        query = [PFQuery queryWithClassName:[self tableName: objectType]];
    }
    
    if (orderByKey)
    {
        ascending ? [query orderByAscending:orderByKey] :[query orderByDescending:orderByKey];
    }
    
    NSString *cacheKey = [self hashkey:predicate ofType:objectType offset:offset limit:limit];
    /*
     id cachedObject = [self cachedDataForKey:cacheKey ofType:objectType];
    if (cachedObject)
    {
        callback(cachedObject);
        return;
    }*/
    query.skip = offset;
    query.limit = limit;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            errorCallback(error);
        }
        else
        {
            NSMutableArray *results = [NSMutableArray array];
            
            for (PFObject *item in objects)
            {
                [results addObject:[self toDictionary:item]];
            }
            NSMutableDictionary *response = [NSMutableDictionary dictionary];
            [response setObject:results forKey:PAYLOAD];
            [response setObject:[NSDate date] forKey:CACHED_AT];
            [self cacheData:response forKey:cacheKey];
            [loadedObjectTypes setObject:[NSDate date] forKey:cacheKey];
            callback(response);
        }
    }];
}

- (NSArray *) getObjects: (NSPredicate *) predicate
                  ofType: (NSString *) objectType
                 orderBy: (NSString *) orderByKey
               ascending: (BOOL) ascending
                  offset: (int) offset
                   limit: (int) limit
                 timeout:(int) timeout
{
    if (!objectType)
    {
        return nil;
    }
    
    PFQuery *query;
    if (predicate)
    {
        query = [PFQuery queryWithClassName:[self tableName: objectType] predicate:predicate];
    }
    else
    {
        query = [PFQuery queryWithClassName:[self tableName: objectType]];
    }

    query.skip = offset;
    query.limit = limit;
    
    if (orderByKey)
    {
        ascending ? [query orderByAscending:orderByKey] : [query orderByDescending:orderByKey];
    }
    
    NSMutableArray *results = [NSMutableArray array];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        for (PFObject *item in [query findObjects])
        {
            [results addObject:[self toDictionary:item]];
        }
    }];
    
    [queue addOperation:operation];
    [queue waitUntilAllOperationsAreFinished];
    
    NSMutableDictionary *response = [NSMutableDictionary dictionary];
    
    [response setObject:results forKey:PAYLOAD];
    //[self cacheData:response forKey:cacheKey];
    return results;
}

#pragma cache
- (id) cachedDataForKey:(NSString *) cacheKey
{
    NSDictionary *data = [[SSCacheManager cacheManager] get:cacheKey];
    if(!data)
    {
        return nil;
    }
    NSDate *dateCached = [data objectForKey: CACHED_AT];
    if ([dateCached timeIntervalSinceNow] < -ONE_DAY)
    {
        return nil;
    }
    return [data objectForKey:CACHED_DATA];
}
- (void) invaliateCacheDataForKey:(NSString *) cacheKey
{
    [[SSCacheManager cacheManager] invalidateOfType:cacheKey];
}

- (void) cacheData:(id) data forKey:(NSString *) cacheKey
{
    if (!data)
    {
        DebugLog(@"Can't cache nil for key %@", cacheKey);
        return;
    }
    
    NSMutableDictionary *cachedObject = [NSMutableDictionary dictionary];
    [cachedObject setObject:[NSDate date] forKey:CACHED_AT];
    [cachedObject setObject:data ? data : [NSNull null] forKey:CACHED_DATA];
    [[SSCacheManager cacheManager] put:cachedObject ofType:cacheKey];
}

- (id) cachedDataForKey:(NSString *) cacheKey
                 ofType:(NSString *) objectType
{
    id cachedObject = [[SSCacheManager cacheManager] get:cacheKey];
    if (cachedObject)
    {
        NSDate * date = [cachedObject objectForKey:CACHED_AT];
        NSDate * invalidated = [invalidatedObjectTypes objectForKey:objectType];
        if(!invalidated || [invalidated isEqualToDate:[invalidated earlierDate : date]])
        {
            return [cachedObject objectForKey:CACHED_DATA];
        }
    }
    return nil;
}

#pragma file upload

- (id) getMyFileObject:(NSString *) filename
{
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: FILE_CLASS]];
    [query whereKey:AUTHOR equalTo:[SSProfileVC profileId]];
    [query whereKey:FILE_NAME_KEY equalTo:filename];
    NSArray *array = [query findObjects];
    return [array count]==0?nil : [array objectAtIndex:0];
}

- (id) getFileObject:(NSString *) filename
{
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: FILE_CLASS]];
    [query whereKey:FILE_NAME_KEY equalTo:filename];
    NSArray *array = [query findObjects];
    return [array count]==0?nil : [array objectAtIndex:0];
}

//down load data from any url, not parse
- (void)downloadFile: (NSString *) url
           onSuccess: (SuccessDownload) callback
           onFailure: (ErrorCallback) errorCallback
{
    HTTPConnector *http = [[HTTPConnector alloc]init];
    [http downloadFile:url onSuccess:^(NSData *data) {
        callback(data);
    } onProgress:^(id data) {
        //does nothing for now
    } onFailure:^(NSError *error) {
        errorCallback(error);
    }];
}

- (void)downloadData: (NSString *) filename
           onSuccess: (SuccessDownload) callback
           onFailure: (ErrorCallback) errorCallback
{
    [self downloadData:filename forUser:[PFUser currentUser].username onSuccess:callback onFailure:errorCallback];
}


- (void)downloadData: (NSString *) filename
             forUser: (NSString *) username
           onSuccess: (SuccessDownload) callback
           onFailure: (ErrorCallback) errorCallback
{
    NSString *fileIdKey = filename;
    id cachedFileId = [self cachedDataForKey:fileIdKey];
    if(cachedFileId)
    {
        NSData *cachedData = [self cachedDataForKey:cachedFileId];
        if(cachedData != nil && [cachedData length] > 0)
        {
            callback(cachedData);
            cachedData = nil;
            return;
        }
    }
    
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: FILE_CLASS]];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query whereKey:FILE_NAME_KEY equalTo:filename];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             errorCallback(error);
             return;
         }
         if (objects.count > 0)
         {
             PFObject *fileObj = [objects objectAtIndex:objects.count - 1];
             __block NSData *cachedData = [self cachedDataForKey:fileObj.objectId];
             if(cachedData != nil && [cachedData length] > 0)
             {
                 callback(cachedData);
                 cachedData = nil;
                 return;
             }
             
             PFFile *file = [fileObj objectForKey:FILE_KEY];
             [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                 if (error)
                 {
                     errorCallback(error);
                 }
                 else
                 {
                     [self cacheData:data forKey:fileObj.objectId];
                     [self cacheData:fileObj.objectId forKey:filename];
                     callback(data);
                 }
             }];
             return;
         }
         else
         {
             callback(nil);
         }
     }];
}

- (void) replaceData:(NSData *) data
            fileName:(NSString*) filename
           onSuccess: (SuccessCallback) callback
           onFailure: (ErrorCallback) errorCallback
{
    PFObject *pfObject = [self getFileObject:filename];
    if (pfObject)
    {
        [pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 [self uploadData:data fileName:filename onSuccess:^(id data) {
                     callback(data);
                 } onFailure:^(NSError *error) {
                     errorCallback(error);
                 }];
             }
             else
             {
                errorCallback(error);
             }
         }
         ];
        return;
    }
    else
    {
        [self uploadData:data fileName:filename onSuccess:^(id data) {
            callback(data);
        } onFailure:^(NSError *error) {
            errorCallback(error);
        }];
    }
}

- (void) replaceFile: (NSData *) data
            fileName: (NSString*) filename
        fileObjectId: fileId
           onSuccess: (SuccessCallback) callback
           onFailure: (ErrorCallback) errorCallback
{
    
    if (!filename || !fileId || ![PFUser currentUser])
    {
        errorCallback([[NSError alloc]initWithDomain:@"Upload File" code:20001 userInfo:nil]);
        return;
    }
    
    PFFile *file = [PFFile fileWithName:filename data:data];
    
    PFObject *fileObj = [self getFileObject:filename];
    
    if (fileObj)
    {
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [fileObj setObject:file forKey:FILE_KEY];
                 [self cacheData:data forKey:fileId];
                [fileObj saveEventually];
                callback(nil);
            }
            else
            {
                errorCallback(error);
            }
        } progressBlock:^(int percentDone) {
            
        }];
    }
}

- (void) uploadFile: (NSData *) data
           fileName: (NSString*) filename
        relatedType: (NSString *) objectType
          relatedId: (NSString *) objectId
               desc: (NSString *) desc
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback
{
    [self uploadFile:data
            fileName:filename
         relatedType:objectType
           relatedId:objectId
            fileType:@"Img"
                desc:desc
           onSuccess:callback
           onFailure:errorCallback];
}

- (void) replaceFile: (NSData *) data
           fileName: (NSString*) filename
        relatedType: (NSString *) objectType
          relatedId: (NSString *) objectId
           fileType: (NSString *) fileType
               desc: (NSString *) desc
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback
{
    
    if (!filename || ![PFUser currentUser])
    {
        errorCallback([[NSError alloc]initWithDomain:@"Upload File" code:20001 userInfo:nil]);
        return;
    }
    
    PFObject *pfObject = [self getFileObject:filename];
    if (pfObject)
    {
        [pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (succeeded)
             {
                 [self uploadFile:data
                         fileName:filename
                        relatedType:objectType
                        relatedId:objectId
                         fileType:fileType
                             type:@"icon"
                             desc:desc
                        onSuccess:^(id data) {
                     callback(data);
                 } onFailure:^(NSError *error) {
                     errorCallback(error);
                 }];
             }
             else
             {
                 errorCallback(error);
             }
         }
         ];
        return;
    }
    else
    {
        [self uploadFile:data
                fileName:filename
             relatedType:objectType
               relatedId:objectId
                fileType:fileType
                    type:@"icon"
                    desc:desc
               onSuccess:^(id data) {
                   callback(data);
               } onFailure:^(NSError *error) {
                   errorCallback(error);
               }];
    }

    
}

- (void) uploadFile: (NSData *) data
           fileName: (NSString*) filename
        relatedType: (NSString *) objectType
          relatedId: (NSString *) objectId
           fileType: (NSString *) fileType
               desc: (NSString *) desc
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback
{
    [self uploadFile:data fileName:filename relatedType:objectType relatedId:objectId fileType:fileType type:@"" desc:desc onSuccess: callback onFailure:errorCallback];
}

- (void) uploadFile: (NSData *) data
           fileName: (NSString*) filename
        relatedType: (NSString *) objectType
          relatedId: (NSString *) objectId
           fileType: (NSString *) fileType
               type: (NSString *) type
               desc: (NSString *) desc
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback
{
    if (!filename || !objectType || !objectId || ![PFUser currentUser])
    {
        errorCallback([[NSError alloc]initWithDomain:@"Upload File" code:20001 userInfo:nil]);
        return;
    }
    NSString *fileIdKey = filename;
    id cachedFileId = [self cachedDataForKey:fileIdKey];
    if(cachedFileId)
    {
        [self invaliateCacheDataForKey:filename];
        [self invaliateCacheDataForKey:cachedFileId];
    }
    
    PFFile *file = [PFFile fileWithName:filename data:data];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFObject *fileObject = [PFObject objectWithClassName:[self tableName: FILE_CLASS]];
            [fileObject setObject:file forKey:FILE_KEY];
            [fileObject setObject:fileType forKey:FILE_TYPE];
            [fileObject setObject:filename forKey:FILE_NAME_KEY];
            [fileObject setValue:objectType forKey:RELATED_TYPE];
            [fileObject setValue:objectId forKey:RELATED_ID];
            [fileObject setValue:type forKey:SS_TYPE];
            [fileObject setValue:desc ? desc : filename forKey:DESC];
            [fileObject setObject:[SSProfileVC profileId] forKey:AUTHOR];
            [fileObject setObject:[self userInfo] forKey:USER_INFO];
            [fileObject setObject:[NSNumber numberWithInt:(int)[data length]] forKey:FILE_SIZE];
            [fileObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    callback(fileObject);
                }
                else{
                    errorCallback(error);
                }
            }];
            
        }
        else
        {
            DebugLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        
    }];
}

- (NSDictionary *) userInfo
{
    return [[SSApp instance] contextualObject:[SSProfileVC profile] ofType:PROFILE_CLASS];
}

- (void) uploadData:(NSData *) data
           fileName:(NSString*) filename
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback
{
    
    NSString *fileIdKey = filename;
    id cachedFileId = [self cachedDataForKey:fileIdKey];
    if(cachedFileId)
    {
        [self invaliateCacheDataForKey:filename];
        [self invaliateCacheDataForKey:cachedFileId];
    }
    
    PFFile *file = [PFFile fileWithName:filename data:data];
    
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error)
         {
             PFObject *fileObject = [PFObject objectWithClassName:[self tableName: FILE_CLASS]];
             [fileObject setObject:file forKey:FILE_KEY];
             [fileObject setObject:filename forKey:FILE_NAME_KEY];
             [fileObject setObject:[SSProfileVC profileId] forKey:AUTHOR];
             [fileObject setObject:[self userInfo] forKey:USER_INFO];
             [fileObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  if (!error)
                  {
                      [self cacheData:data forKey:fileObject.objectId];
                      callback(fileObject);
                  }
                  else
                  {
                      errorCallback(error);
                  }
              }];
         }
         else
         {
             errorCallback(error);
         }
     } progressBlock:^(int percentDone) {
         
     }];
}

- (void) countObjectsOfType:(NSString *)objectType onSuccess:(SuccessCallback)callback
{
    PFQuery *query = [PFQuery queryWithClassName:[self tableName: objectType]];
    
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            callback([NSNumber numberWithInteger:count]);
        } else {
            callback([NSNumber numberWithInteger:-1]);
        }
    }];
}

#pragma security

- (void) deleteAccount:(id) profile
{
    [self deleteObjectById:[profile objectForKey:REF_ID_NAME] ofType:PROFILE_CLASS];
}
//user object is deleted on the server via cloud code
- (void) deleteMyAccount
{
    [self deleteObjectById:[[SSProfileVC profile] objectForKey:REF_ID_NAME] ofType:PROFILE_CLASS];
}


#pragma Push
#define CHANNELS @"channels"

- (void) subscribeToChannel:(NSString *) channelName
{
    [[PFInstallation currentInstallation] addUniqueObject:channelName forKey:CHANNELS];
    [[PFInstallation currentInstallation] saveEventually];
}

- (void) unsubscribeToChannel:(NSString *) channelName
{
    [[PFInstallation currentInstallation] removeObject:channelName forKey:CHANNELS];
    [[PFInstallation currentInstallation] saveEventually];
}

- (void) push:(NSString *) msg toChannel:(NSString *) channelName
{
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          msg, @"alert",
                          //@"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          nil];
    
    [self pushToChannel:channelName withData:data];
}

- (void) pushToChannel:(NSString *) channelName withData:(id) data
{
    NSArray *channels = [NSArray arrayWithObjects:channelName, nil];
    PFPush *push = [[PFPush alloc] init];
    [push setChannels:channels];
    [push setData:data];
    [push sendPushInBackground];
}

//
- (void) pushNotification:(NSString *) msg toUsersMatches:(PFQuery *) userQuery
{
    // Build the actual push notification target query
    PFQuery *query = [PFInstallation query];
    // only return Installations that belong to a User that
    // matches the innerQuery
    [query whereKey:USER matchesQuery:userQuery];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setMessage:msg];
    [push sendPushInBackground];
}


@end
