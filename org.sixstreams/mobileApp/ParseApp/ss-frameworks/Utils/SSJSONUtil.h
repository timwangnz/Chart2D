//
//  JSONUtil.h
//  JobsExchange
//
//  Created by Anping Wang on 2/2/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SSJSONUtil : NSObject

+ (NSString *) cancate: (NSString *) first, ...;

@end

@interface NSString (JSONUtil)
+ (BOOL) isEmpty :(NSString *) value;
- (NSDictionary *) toDictionary;
- (NSDate *) toDate;
- (NSString *) toPhoneNumber;
- (NSString *) toBase64;
- (NSString *) fromBase64;
- (NSString *) urlEncoded;
- (NSString *) fromCamelCase;
- (NSString *) toCurrency;
- (NSString *) toNumber;

- (id) toKeywordList;
@end

@interface NSArray(JSONUtil)
- (id) toKeywordList;
@end

@interface NSData (JSONUtil)
- (NSDictionary *) toDictionary;
- (NSString *) toString;
@end

@interface NSDictionary(JSONUtil)
- (id) JSONString;
- (id) JSONData;
- (id) objectForKeyWithoutNil:(id) aKey;
- (id) valueForPath:(NSString *) path;
- (NSDictionary *) subset:(NSArray *) keys;
@end

@interface NSMutableDictionary(JSONUtil)
- (void) setValue:(id)value forKey:(NSString *)key;
- (void) copy:(id)sender;
@end

@interface NSDate(JSONUtil)
- (NSString *) toString;
- (NSString *) since;
- (NSString *) toDateString;
- (NSString *) toDateTimeString;
- (NSString *) toTimeString;
- (NSString *) toYearMonthString;
- (NSString *) toDateMonthString;
- (NSString *) toDayString;
- (NSDate *) firstDateOfMonth;
- (BOOL) isToday;
@end
