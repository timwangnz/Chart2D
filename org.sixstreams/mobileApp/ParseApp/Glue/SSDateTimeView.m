//
//  SSDateTimeView.m
//  SixStreams
//
//  Created by Anping Wang on 8/26/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSDateTimeView.h"
#import "SSJSONUtil.h"

@implementation SSDateTimeView

- (void) setDatetime:(NSDate *)datetime
{
    self.date.text = [datetime toDateMonthString];
    self.time.text = [datetime toTimeString];
    self.day.text = [datetime toDayString];
}

@end
