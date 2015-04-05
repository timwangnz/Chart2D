//
//  TimeUtil.m
//  iSwim2.0
//
//  Created by Anping Wang on 3/5/11.
//  Copyright 2011 s. All rights reserved.
//

#import "SSTimeUtil.h"

@implementation SSTimeUtil

+(NSString *) stringWithTime:(int) time
{
	if (time <= 0)
	{
		return @"";
	}
    
	int minutes = time / 60000;
	int seconds = (time - minutes * 60000) / 1000;
	int subsecs = (time - seconds * 1000 - minutes * 60000) / 10;
    
	NSString *displayName = [NSString stringWithFormat:@"%02d:%02d.%02d", minutes, seconds, subsecs];
	return displayName;	
}	   

+ (NSDate *)dateAYearAgo:(NSDate *)from
{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:-1];
    
    return [gregorian dateByAddingComponents:offsetComponents toDate:from options:0];
    
}

+(NSString *) stringWithDateTime:(NSDate *) date
{
	if (!date)
	{
		return @"";
	}
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormatter stringFromDate:date];
	return dateString;	
}

+(NSString *) stringFromDateWithFormat:(NSString *)format date:(NSDate *) date;
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:format];
    NSString *formattedDate = [dateFormat stringFromDate:date];
    return formattedDate;
}

+(NSDate *) dateFromStringWithFormat:(NSString *)format dateString:(NSString *) date;
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    return [dateFormat dateFromString:date];
}

+(NSString *) stringWithShortDate:(NSDate *) date
{
    return [self stringFromDateWithFormat:@"MM-dd-yyyy" date:date];
}

+(NSDate *) dateWithShortString:(NSString *) dateString
{
    return [self dateFromStringWithFormat:@"MM-dd-yyyy" dateString : dateString];
}

+(NSString *) stringWithDate:(NSDate *) date
{
	if (!date)
	{
		return @"";
	}
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    NSString *dateString = [dateFormatter stringFromDate:date];
	return dateString;	
}	 

+(NSString *) formatWithDateTime:(NSDate *) date mode : (NSString *) mode
{
	if (!date)
	{
		return @"";
	}
    if ([mode isEqualToString:@"datetime"])
    {
        return [self stringWithDateTime:date];
    }
    else
    {
        return [self stringWithDate:date];
    }	
}



+(NSDate *) dateFromString:(NSString *) dateString
{
	if (!dateString)
	{
		return nil;
	}
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    return [dateFormatter dateFromString:dateString];

}	 

+(NSDate *) dateTimeFromString:(NSString *) dateString
{
	if (!dateString)
	{
		return nil;
	}
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter dateFromString:dateString];
    
}	 

+(NSArray *) componentsWithTime:(int) time
{
	if (time <= 0)
	{
		return nil;
	}
	int minutes = time / 60000;
	int seconds = (time - minutes * 60000) / 1000;
	int subsecs = (time - seconds * 1000 - minutes * 60000) / 10;
    NSMutableArray *comps = [[NSMutableArray alloc]init];
    [comps addObject:[NSNumber numberWithInteger:minutes]];
    [comps addObject:[NSNumber numberWithInteger:seconds]];
    [comps addObject:[NSNumber numberWithInteger:subsecs]];
    return comps;
	
}	
@end
