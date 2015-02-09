//
// AppliaticsCacheManager.m
// Appliatics
//
//  Created by Anping Wang on 9/28/13.
//

#import "SSCacheManager.h"
#import "SSStorageManager.h"
#import "DebugLogger.h"

@interface SSCacheManager ()
{
    NSMutableDictionary *inMemoryCache;
}
@end

@implementation SSCacheManager

static SSCacheManager *cacheManager;

static NSString *_ROOT_PATH = @"Documents";
static NSString *_NS_PREFIX = @"SIX";

static NSString *_DEFAULT_DELIMITER_REPLACEMENT = @"_";

+ (SSCacheManager *) cacheManager
{
    if (!cacheManager)
    {
        cacheManager = [[SSCacheManager alloc]init];
    }
    return cacheManager;
}

- (void) invalidateOfType:(NSString *) objectType
{
    if (inMemoryCache)
    {
        [inMemoryCache removeObjectForKey:objectType];
    }
    [[SSStorageManager storageManager] delete:objectType];
}

- (void) put:(id) object ofType:(NSString *) objectType
{
    if (!objectType)
    {
        DebugLog(@"Failed to cache object as objectType is nil");
        return;
    }
    if (!inMemoryCache)
    {
        inMemoryCache = [NSMutableDictionary dictionary];
    }
    if (object)
    {
        [[SSStorageManager storageManager] save:object uri:objectType];
    }
    else
    {
        DebugLog(@"Failed to cache object as object is nil");
    }
}

- (id) get:(NSString *) objectType
{
    if (!inMemoryCache)
    {
        inMemoryCache = [NSMutableDictionary dictionary];
    }
    id cachedObject = [inMemoryCache valueForKey:objectType];
    if (cachedObject)
    {
        return cachedObject;
    }
    cachedObject = [[SSStorageManager storageManager] read:objectType];
    return cachedObject;
}

@end
