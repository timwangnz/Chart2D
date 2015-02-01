//
//  SCSynchronizer.h
// Appliatics
//
//  Created by Anping Wang on 9/23/13.
//

#import <Foundation/Foundation.h>
#import "DebugLogger.h"

typedef void (^SuccessDownload)(NSData *data);
typedef void (^SuccessCallback)(id data);
typedef void (^ProgressCallback)(id data);
//one call return both
typedef void (^StorageCallback)(id data, NSError *error);
typedef void (^ErrorCallback)(NSError *error);

@class SSConnection;

@protocol SSCrudListener <NSObject>
@optional
- (void) connection:(SSConnection *) connection didCreate:(id) object ofType: (NSString*) objectType;
- (void) connection:(SSConnection *) connection didDelete:(id) object ofType: (NSString*) objectType;
- (void) connection:(SSConnection *) connection didUpdate:(id) object ofType: (NSString*) objectType;
- (void) connection:(SSConnection *) connection didGet:(id) object ofType: (NSString*) objectType;
@end


@interface SSConnection : NSObject

+ (SSConnection *) connector;

@property (nonatomic, strong) NSString *objectType;
//when specified, all calls will be waiting for timeout. If it is 0, calls are async
@property int timeout;

+ (void) addCrudListener:(id<SSCrudListener>) crudListener;
+ (void) removeCrudListener:(id<SSCrudListener>) crudListener;

- (void) uploadObjects: (NSArray *)objects
                ofType: (NSString *)objectType;

- (void) createObject: (NSDictionary *) data
               ofType: (NSString *) objectType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback;

- (void) updateObject: (NSDictionary *) data
               ofType: (NSString *) objectType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback;

- (void) deleteByFilters: (NSArray *) filters
                  ofType: (NSString *) objectType
               onSuccess: (SuccessCallback) callback
               onFailure: (ErrorCallback) errorCallback;

- (void) deleteObject: (NSDictionary *) item
               ofType: (NSString *) objectType
             onSuccess: (SuccessCallback) callback
             onFailure: (ErrorCallback) errorCallback;

- (void) refreshObject: (NSDictionary *) data
               ofType: (NSString *) objectType
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback;

- (void) objects: (NSPredicate *) predicate
          ofType: (NSString *) objectType
         orderBy: (NSString *) orderByKey
       ascending: (BOOL) ascending
          offset: (int) offset
           limit: (int) limit
       onSuccess: (SuccessCallback) callback
       onFailure: (ErrorCallback) errorCallback;

- (void) objectForKey: (NSString *) objectId
                ofType: (NSString *) objectType
             onSuccess: (SuccessCallback) callback
             onFailure: (ErrorCallback) errorCallback;


- (NSArray *) getObjects: (NSPredicate *) predicate
                         ofType: (NSString *) objectType
                        orderBy: (NSString *) orderByKey
                      ascending: (BOOL) ascending
                         offset:(int) offset
                          limit:(int) limit
                        timeout:(int) timeout;

- (id) objectForKey: (NSString *) objectId
             ofType: (NSString *) type;

//bulk save
- (void) saveAll: (NSArray *) items
            type: (NSString *) type
       onSuccess: (SuccessCallback) callback
       onFailure: (ErrorCallback) errorCallback;

- (void) deleteObjectById: (NSString *) objectId
                   ofType: (NSString *) type;

- (void) deleteObjectById: (NSString *) objectId
                   ofType: (NSString *) type
                onSuccess: (SuccessCallback) callback
                onFailure: (ErrorCallback) errorCallback;


- (void) deleteChildren: (NSString*) parentId
                 forKey:(NSString *) key
                 ofType:(NSString *) type
              onSuccess: (SuccessCallback) callback
              onFailure: (ErrorCallback) errorCallback;


- (void) getChildren : (NSString*) parentId
                    forKey: (NSString *) key
                    ofType: (NSString *) type
                 onSuccess: (SuccessCallback) callback
                 onFailure: (ErrorCallback) errorCallback;

- (void) getChildren : (NSString*) parentId
               forKey: (NSString *) key
               ofType: (NSString *) type
                since: (NSDate *) date
            onSuccess: (SuccessCallback) callback
            onFailure: (ErrorCallback) errorCallback;

- (void) deleteObjectsWithFilters: (NSArray *) filters
                           ofType: (NSString *) objectType
                        onSuccess: (SuccessCallback) callback
                        onFailure: (ErrorCallback) errorCallback;

- (void) objectsWithPrefix: (NSString *) prefix
                     onKey: (NSString *) key
                   filters: (NSArray *) filters
                    ofType: (NSString *) objectType
                   orderBy: (NSString *) orderByKey
                 ascending: (BOOL) ascending
                    offset: (NSUInteger) offset
                     limit: (NSUInteger) limit
                 onSuccess: (SuccessCallback) callback
                 onFailure: (ErrorCallback) errorCallback;

- (void) objectsWithFilters: (NSArray *) filters
                     ofType: (NSString *) objectType
                    orderBy: (NSString *) orderByKey
                  ascending: (BOOL) ascending
                     offset: (NSUInteger) offset
                      limit: (NSUInteger) limit
                  onSuccess: (SuccessCallback) callback
                  onFailure: (ErrorCallback) errorCallback;

- (void) downloadFile: (NSString *) url
            onSuccess: (SuccessDownload) callback
            onFailure: (ErrorCallback) errorCallback;

- (void) replaceFile: (NSData *) data
            fileName: (NSString*) filename
        fileObjectId: fileId
           onSuccess: (SuccessCallback) callback
           onFailure: (ErrorCallback) errorCallback;

//delete before upload
- (void) replaceFile: (NSData *) data
           fileName: (NSString*) filename
        relatedType: (NSString *) objectType
          relatedId: (NSString *) objectId
           fileType: (NSString *) fileType
               desc: (NSString *) desc
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback;

- (void) uploadFile: (NSData *) data
           fileName: (NSString*) filename
        relatedType: (NSString *) objectType
          relatedId: (NSString *) objectId
           fileType: (NSString *) fileType
               desc: (NSString *) desc
          onSuccess: (SuccessCallback) callback
          onFailure: (ErrorCallback) errorCallback;

- (void)downloadData:(NSString *) filename
             forUser:(NSString *) username
           onSuccess: (SuccessDownload) callback
           onFailure: (ErrorCallback) errorCallback;

- (void)downloadData:(NSString *) filename
           onSuccess: (SuccessDownload) callback
           onFailure: (ErrorCallback) errorCallback;

- (void) countObjectsOfType: (NSString *) objectType
                  onSuccess: (SuccessCallback) callback;

//Security API

- (void) deleteAccount:(id) profile;
- (void) deleteMyAccount;

//Notifications


- (void) subscribeToChannel:(NSString *) channelName;
- (void) unsubscribeToChannel:(NSString *) channelName;
- (void) push:(NSString *) msg toChannel:(NSString *) channelName;
- (void) pushToChannel: (NSString *) channelName withData:(id) data;

- (void) objectsOfType: (NSString *) type
              authorId: (NSString *) authorId
             onSuccess: (SuccessCallback) callback
             onFailure: (ErrorCallback) errorCallback;

- (void) myObjectsOfType: (NSString *) type
               onSuccess: (SuccessCallback) callback
               onFailure: (ErrorCallback) errorCallback;


+ (NSString *) objectType:(NSString *) className;

@end
