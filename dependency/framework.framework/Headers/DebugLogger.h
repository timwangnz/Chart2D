//
//  OPCDebug.h
//  Oracle Daas
//
//  Created by Anping Wang on 9/17/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DebugLogger : NSObject

#ifdef DEBUG
#   define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DebugLog(...)
#endif
/*
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif
*/
@end
