//
//  SSCalendarConnector.h
//  SixStreams
//
//  Created by Anping Wang on 5/25/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface SSCalendarConnector : NSObject

+ (NSArray *) getEvents;
+ (BOOL) check;
@end
