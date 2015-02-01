//
//  TimeUtil.h
//  iSwim2.0
//
//  Created by Anping Wang on 3/5/11.
//  Copyright 2011 s. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SSTimeUtil : NSObject {

}
+(NSDate *) dateTimeFromString:(NSString *) dateString;
+(NSString *) formatWithDateTime:(NSDate *) date mode : (NSString *) mode;

+(NSString *) stringWithTime:(int) time;
+(NSArray *) componentsWithTime:(int) time;
+(NSString *) stringWithDate:(NSDate *) date;
+(NSDate *) dateFromString:(NSString *) dateString;
+(NSString *) stringWithDateTime:(NSDate *) date;
+(NSString *) stringFromDateWithFormat:(NSString *)format date:(NSDate *) date;
+(NSDate *) dateFromStringWithFormat:(NSString *)format dateString:(NSString *) date;

+(NSString *) stringWithShortDate:(NSDate *) date;
+(NSDate *) dateWithShortString:(NSString *) dateString;

@end
