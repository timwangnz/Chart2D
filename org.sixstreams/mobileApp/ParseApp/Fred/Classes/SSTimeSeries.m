//
//  SSTimeSeries.m
//  SixStreams
//
//  Created by Anping Wang on 3/28/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSTimeSeries.h"
#import "SSTimeUtil.h"

@implementation SSTimeSeries

- (NSDate *)toDate:(NSString *) dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (!dateString)
    {
        return nil;
    }
    dateFormatter.dateFormat = @"yyyy-mm-dd";
    return [dateFormatter dateFromString:dateString];
    
}

- (id) initWithDictionary:(id) dict
{
    self = [super init];
    if (self) {
        self.seriesDef = dict[@"seriesDef"];
        self.frequency = self.seriesDef[@"frequence"];
        self.units = self.seriesDef[@"units"];
        self.categoryId = self.seriesDef[@"id"];
        NSMutableDictionary *dataPoints = [NSMutableDictionary dictionary];
        NSMutableArray *xPoints = [NSMutableArray array];
        self.seriesStyle = [Graph2DSeriesStyle defaultStyle:Graph2DLineChart];
        self.seriesStyle.fillStyle = nil;
        self.seriesStyle.gradient = NO;
        id observations = dict[@"observations"];
        float lastValue = 0;
        for (id observation in observations) {
            float value = [observation[@"value"] floatValue];
            if (value == 0)
            {
                value = lastValue;
            }
            lastValue = value;
            NSDate *date = observation[@"date"];//[self toDate:observation[@"date"]];
            if(date != nil)
            {
                [dataPoints setObject:[NSNumber numberWithFloat:value] forKey:date];
                 [xPoints addObject:date];
            }
        }
        self.dataPoints = [NSDictionary dictionaryWithDictionary:dataPoints];
        self.xPoints = [NSArray arrayWithArray:xPoints];
        self.title = dict[@"title"];
        self.units = self.seriesDef[@"frequency_short"];
    }
    return self;
}

- (NSNumber *) valueAt:(NSInteger) index
{
    return self.dataPoints[self.xPoints[index]];
}

- (NSNumber *) valueFor:(id) key
{
    if(self.dataPoints[key])
    {
        NSNumber * fValue = self.dataPoints[key];
        return fValue;
    }else
    {
        return nil;
    }
}

- (NSNumber *) growthRatioBetween:(id) first and:(id) second
{
    if(self.dataPoints[first] && self.dataPoints[second])
    {
        float fValue = [self.dataPoints[first] floatValue];
        float sValue = [self.dataPoints[second] floatValue];
        if (sValue == fValue)
        {
            return [NSNumber numberWithFloat:0];;
        }
        if (fValue == 0)
        {
            return [NSNumber numberWithFloat:0];;
        }
        return [NSNumber numberWithFloat:(sValue - fValue)*100/fValue];
    }
    else
    {
        return [NSNumber numberWithFloat:0];
    }
}

@end
