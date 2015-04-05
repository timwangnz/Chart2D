//
//  SSTimeSeries.m
//  SixStreams
//
//  Created by Anping Wang on 3/28/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSTimeSeries.h"

@implementation SSTimeSeries

- (id) initWithDictionary:(id) dict
{
    self = [super init];
    if (self) {
        id seriesDef = dict[@"seriesDef"];
        self.frequency = seriesDef[@"frequence"];
        self.units = seriesDef[@"units"];
        self.id = seriesDef[@"id"];
        NSMutableDictionary *dataPoints = [NSMutableDictionary dictionary];
        NSMutableArray *xPoints = [NSMutableArray array];
        id observations = dict[@"observations"];
        float lastValue = 0;
        for (id observation in observations) {
            float value = [observation[@"value"] floatValue];
            if (value == 0)
            {
                value = lastValue;
            }
            lastValue = value;
            [dataPoints setObject:[NSNumber numberWithFloat:value] forKey:observation[@"date"]];
            [xPoints addObject:observation[@"date"]];
        }
        self.dataPoints = [NSDictionary dictionaryWithDictionary:dataPoints];
        self.xPoints = [NSArray arrayWithArray:xPoints];
        self.title = dict[@"title"];
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
        return [NSNumber numberWithFloat:(sValue - fValue)/fValue];
    }
    else
    {
        return [NSNumber numberWithFloat:0];
    }
}

@end
