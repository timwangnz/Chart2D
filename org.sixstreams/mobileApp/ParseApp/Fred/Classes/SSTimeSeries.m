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
        self.id = dict[@"id"];
        NSMutableDictionary *dataPoints = [NSMutableDictionary dictionary];
        NSMutableArray *xPoints = [NSMutableArray array];
        id observations = dict[@"observations"];
        
        for (id observation in observations) {
            [dataPoints setObject:observation[@"value"] forKey:observation[@"date"]];
            [xPoints addObject:observation[@"date"]];
        }
        self.dataPoints = [NSDictionary dictionaryWithDictionary:dataPoints];
        self.xPoints = [NSArray arrayWithArray:xPoints];
        self.title = dict[@"title"];
    }
    return self;
}


@end
