//
//  JSONUtil.m
//  JobsExchange
//
//  Created by Anping Wang on 2/2/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSJSONUtil.h"
#import "DebugLogger.h"
#import "SSBase64.h"
#import "SSApp.h"

@implementation SSJSONUtil

+ (NSString *) cancate: (NSString *) first, ...
{
    NSString * result = @"";
    id eachArg;
    va_list alist;
    if(first)
    {
    	result = [result stringByAppendingString:first];
    	va_start(alist, first);
    	while ((eachArg = va_arg(alist, id)))
        {
    		result = [result stringByAppendingString:eachArg];
        }
    	va_end(alist);
    }
    return result;
}
@end

@implementation NSDate(JSONUtil)

static NSDateFormatter *dateFormatter = nil;

+ (NSDateFormatter *) getDateFormatter
{
    //if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return dateFormatter;
}

- (BOOL) isToday
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:self];
    NSDate *otherDate = [cal dateFromComponents:components];
    return [today isEqualToDate:otherDate];
}

- (NSString *) toYearMonthString
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/yy"];
    return [dateFormatter stringFromDate : self];
}

- (NSString *) toDateTimeString
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd hh:mm"];
    return [dateFormatter stringFromDate : self];
}

- (NSString *) toDateMonthString
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    return [dateFormatter stringFromDate : self];
}

- (NSString *) toDayString
{
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"EEE";
    return [[dateFormatter stringFromDate : self] uppercaseString];
}

- (NSString *) toDateString
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
    return [dateFormatter stringFromDate : self];
}

- (NSString *) toTimeString
{
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate : self];
}

- (NSString *) toString
{
    return [[NSDate getDateFormatter] stringFromDate : self];
}

- (NSString *) since
{
    NSTimeInterval secondsBetween = -[self timeIntervalSinceNow];
    
    if (secondsBetween < 60)
    {
        return [NSString stringWithFormat:@"%.0f secs", secondsBetween];
    }
    else if (secondsBetween < 3600)
    {
        return [NSString stringWithFormat:@"%.0f mins", secondsBetween/60];
    }
    else  if (secondsBetween < 3600 * 24)
    {
        return [NSString stringWithFormat:@"%.0f hrs", secondsBetween/3600];
    }
    else {
        return [NSString stringWithFormat:@"%.0f days", secondsBetween/3600/24];
    }
}

- (NSDate *) firstDateOfMonth
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    [comp setDay:1];
    return [gregorian dateFromComponents:comp];
}

@end

@implementation NSArray(JSONUtil)

- (id) toKeywordList
{
    NSMutableArray *keywords = [[NSMutableArray alloc]init];
    for (NSString *string in self) {
        if(string)
        {
            NSArray *words = [string.lowercaseString componentsSeparatedByString:@" "];
            for(NSString *word in words)
            {
                if (![keywords containsObject:word])
                {
                    [keywords addObject:word];
                }
            }
        }
    }
    return keywords;
}
@end

@implementation NSString (JSONUtil)
- (id) toKeywordList
{
    return [self.lowercaseString componentsSeparatedByString:@" "];
}

NSString *parseName(NSString *input) {
    if(input == nil || [input length] == 0)
    {
        return nil;
    }
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSInteger idx = 0; idx < [input length]; idx += 1) {
        unichar c = [input characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@" %@", [NSString stringWithCharacters:&c length:1]];
        } else {
            [output appendFormat:@"%C", c];
        }
    }
    return [[[output substringToIndex:1] uppercaseString] stringByAppendingString:[output substringFromIndex:1]];
    ;
}

- (NSString *) toNumber
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *c = [NSNumber numberWithDouble:[self doubleValue]];
    return [numberFormatter stringFromNumber:c];
}


- (NSString *) toCurrency
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSNumber *c = [NSNumber numberWithDouble:[self doubleValue]];
    NSString *currencyString = [numberFormatter stringFromNumber:c];
    
    return currencyString;
}

- (NSString *) fromCamelCase
{
    NSString *name = NSLocalizedString(self, parseName(self));
    if ([name isEqualToString:self])
    {
        return parseName(self);
    }
    return name;
}

- (NSString *)urlEncoded {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (id) toDictionary
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] toDictionary];
}

- (NSString *) toPhoneNumber
{
    
    NSString *trimmedString = [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedString length] != 10 && [trimmedString length] != 11)
    {
        return self;
    }
    
    NSString *number = trimmedString;
    if ([number length]==10)
    {
        number = [NSString stringWithFormat:@"1%@", number];
    }
    
    NSMutableString *phoneNumber = [[NSMutableString alloc]init];
    NSRange r = NSMakeRange(0,1);
    [phoneNumber appendFormat:@"%@", [number substringWithRange: r]];
    r = NSMakeRange(1,3);
    [phoneNumber appendFormat:@" (%@) ", [number substringWithRange: r]];
    r = NSMakeRange(4,3);
    [phoneNumber appendFormat:@"%@-", [number substringWithRange: r]];
    r = NSMakeRange(7,4);
    [phoneNumber appendFormat:@"%@", [number substringWithRange: r]];
    return phoneNumber;
}

- (NSDate *) toDate
{
    return [[NSDate getDateFormatter] dateFromString :self];
}

- (NSString*) toBase64
{
    return [SSBase64 encode: [self dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString*) fromBase64
{
    return [[NSString alloc] initWithData:[SSBase64 decode : self] encoding:NSUTF8StringEncoding];
}

+ (BOOL) isEmpty :(NSString *) value
{
    return value == nil || [value length] == 0;
}

@end

@implementation  NSData (JSONUtil)
- (id) toDictionary
{
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization
                         JSONObjectWithData:self
                         options:NSJSONReadingMutableContainers
                         error:&error];
    if (error) {
        DebugLog(@"Failed to convert %@ to dictionary due to %@", self, error);
    }
    return dic;

}

- (NSString *) toString
{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end

@implementation  NSDictionary(JSONUtil)

- (NSDictionary *) subset:(NSArray *) keys
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSString *key in keys)
    {
        id value = [self objectForKey:key];
        if (value)
        {
            [dictionary setObject:value forKey:key];
        }
    }
    return dictionary;
}

- (id) childAtPath:(NSString *) path of:(id) parent
{
    NSMutableArray *attrs = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"."]];
    if ([attrs count] == 1)
    {
        return [[SSApp instance] value:self forKey:path] ;
    }
    else{
        id child = [parent objectForKey:[attrs objectAtIndex:0]];
        if(child == nil)
        {
            return nil;
        }
        [attrs removeObject:[attrs objectAtIndex:0]];
        NSString * childPath = [attrs componentsJoinedByString:@"."];
        return [self childAtPath:childPath of:child];
    }
}

- (id) valueForPath:(NSString *)path
{
    if(path && [path length] > 0)
    {
        NSArray *attrs = [path componentsSeparatedByString:@" "];
        NSMutableString *str = [[NSMutableString alloc] init];
        
        for (NSString *attrName in attrs){
            [str appendFormat:@"%@ ",[self childAtPath:attrName of:self]];
        }
        return str;
    }
    return nil;
}

// The NSData MUST be UTF8 encoded JSON.
- (NSString *)JSONString
{
   return [[NSString alloc] initWithData:[self JSONData] encoding:NSUTF8StringEncoding];
}

- (NSData *)JSONData
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        DebugLog(@"Got an error: %@", error);

    } 
    return jsonData;
}

- (id) objectForKeyWithoutNil:(id) aKey
{
    id value = [self objectForKey:aKey];
    if (!value)
    {
        value = @"";
    }
    return value;
}

@end

@implementation NSMutableDictionary(JSONUtil)
- (void) copy:(id)sender
{
    for (NSString *key in [self allKeys]) {
        [self setValue:[sender objectForKey:key] forKey:key];
    }
}
- (void) setValue:(id)value forKey:(NSString *)key
{
    if (!value)
    {
        [self removeObjectForKey:key];
        return;
    }
    [self setObject:value forKey:key];
}

@end

