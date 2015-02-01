//
//  HWDRecognizer.m
//  HandWritingDemo
//
//  Created by Anping Wang on 12/29/12.
//  Copyright (c) 2012 SixStream. All rights reserved.
//

#import "HWDRecognizer.h"
#import "SSLine.h"

#define JSON_TRANAING_SET_NAME_ENG @"SeededTrainedSet"
@interface HWDRecognizer()
{
    NSMutableDictionary *trainedset;
}
@end

@implementation HWDRecognizer

- (id)init
{
    self = [super init];
    if (self) {
        trainedset = [[NSMutableDictionary alloc]init];
        [self loadTrainingSet];

    }
    return self;
}

- (NSString *) match :(SSLine *) lastLine
{
    NSString *bestGuess =nil;
    CGFloat keySimilarity = 1000000000000;
    
    for (NSString *key in [trainedset allKeys])
    {
        NSArray *learnt = [trainedset objectForKey: key];
        if (!learnt || [learnt count] == 0)
        {
            continue;
        }
        for (SSLine *line in learnt)
        {
            CGFloat diff = [lastLine similarTo:line];
            if (diff == 0)
            {
                //NSLog(@"This line should be removed - %d %d", [line count], [lastLine count]);
            }
            else if(diff < keySimilarity)
            {
                bestGuess = key;
                keySimilarity = diff;
                //NSLog(@"ratio %f %f", [lastLine aspectRatio], [line aspectRatio]);
            }
        }
    }
    return bestGuess;
}

- (void) loadTrainingSet
{
    NSString *textPAth = [[NSBundle mainBundle] pathForResource:JSON_TRANAING_SET_NAME_ENG ofType:@"json"];
    NSData *jsonBinary = [NSData dataWithContentsOfFile:textPAth];
    if (jsonBinary == nil)
    {
        return;
    }
    NSMutableDictionary *savedTraineSet = [NSJSONSerialization JSONObjectWithData:jsonBinary options:NSJSONReadingMutableContainers error:nil];
    for (NSString *key in [savedTraineSet allKeys])
    {
        NSArray *lines = [savedTraineSet objectForKey:key];
        NSMutableArray *matchLines = [[NSMutableArray alloc]init];
        for (NSDictionary *lineDic in lines)
        {
            [matchLines addObject: [[SSLine alloc]initWithData:lineDic]];
        }
        [trainedset setObject:matchLines forKey:key];
    }
}

@end
