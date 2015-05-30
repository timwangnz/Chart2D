//
//  SSCalendarConnector.m
//  SixStreams
//
//  Created by Anping Wang on 5/25/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSCalendarConnector.h"

@implementation SSCalendarConnector

+ (void) sync
{
    NSArray *events = [SSCalendarConnector getEvents];
    
    for (EKEvent *event in events)
    {
        NSDictionary *eventData = @{
                                    @"title": event.title,
                                    @"hasAttendees" : event.hasAttendees ? @"T" : @"F",
                                    @"eventIdentifier" :event.eventIdentifier,
                                    @"dateEnd" :event.endDate,
                                    @"dateFrom" :event.startDate,
                                    @"isAllDay" :event.isAllDay ? @"T":@"F",
                                    @"isNew" :event.isNew ? @"T" :@"F",
                                    @"organizerName" :event.organizer ? event.organizer.name : @"",
                                    @"status" : [NSString stringWithFormat:@"%d", event.status],
                                    //      @"URL" :event.URL ? event.URL : @"",
                                    @"timeZone" :event.timeZone ? event.timeZone.name : @"",
                                    //      @"recurrenceRules" :event.recurrenceRules,
                                    @"notes" :event.notes ? event.notes :@"",
                                    @"location" : event.location ? event.location : @""
                                    };
        NSLog(@"%@", eventData);
    }

}

+ (BOOL) check
{
    EKEventStore *store = [[EKEventStore alloc] init];
    BOOL __block myGranted;
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        myGranted = granted;
        if (granted)
        {
            NSLog(@"%@", [self getEvents]);
        }
    }];
    return myGranted;
}

+ (NSArray *) getEvents
{
    // Get the appropriate calendar
    EKEventStore *store = [[EKEventStore alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components
    
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    
    oneDayAgoComponents.day = -1;
    
    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                         
                                                  toDate:[NSDate date]
                         
                                                 options:0];
    
    
    
    // Create the end date components
    
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    
    oneYearFromNowComponents.year = 1;
    
    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                              
                                                       toDate:[NSDate date]
                              
                                                      options:0];
    
    
    
    // Create the predicate from the event store's instance method
    
    NSPredicate *predicate = [store predicateForEventsWithStartDate:oneDayAgo
                                                            endDate:oneYearFromNow
                                                          calendars:nil];
    
    
    
    // Fetch all events that match the predicate
    return [store eventsMatchingPredicate:predicate];
    
}

@end
