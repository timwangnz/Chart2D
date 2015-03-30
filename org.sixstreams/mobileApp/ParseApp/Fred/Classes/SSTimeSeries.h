//
//  SSTimeSeries.h
//  SixStreams
//
//  Created by Anping Wang on 3/28/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//


@interface SSTimeSeries : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *lastUpdated;
@property (nonatomic, retain) NSString *frequency;
@property (nonatomic, retain) NSString *units;
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *reference;
@property (nonatomic, retain) NSDictionary *dataPoints;

@property (nonatomic, retain) NSArray *xPoints;


- (id) initWithDictionary:(id) dict;
- (float) valueAt:(NSInteger) index;
- (float) valueFor:(id) key;

@end
