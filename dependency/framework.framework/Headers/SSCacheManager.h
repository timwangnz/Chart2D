//
// AppliaticsCacheManager.h
// Appliatics
//
//  Created by Anping Wang on 9/28/13.
//

#import <Foundation/Foundation.h>

@interface SSCacheManager : NSObject

+ (SSCacheManager *) cacheManager;

- (void) put:(id) object ofType:(NSString *) objectType;
- (id) get: (NSString *) objectType;
- (void) invalidateOfType:(NSString *) objectType;
@end
