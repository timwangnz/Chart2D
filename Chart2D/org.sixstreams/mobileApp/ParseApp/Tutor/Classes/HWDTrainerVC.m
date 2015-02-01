//
//  HWDTrainerVC.m
//  HandWritingDemo
//
//  Created by Anping Wang on 12/22/12.
//  Copyright (c) 2012 SixStream. All rights reserved.
//

#import "HWDTrainerVC.h"
#import "Graph2DViewDelegate.h"
#import "Vector.h"
#import "Graph2DDataSource.h"
#import "SSGraph.h"

#define JSON_TRANAING_SET_NAME_ENG @"eng.trainedset.json"

#define GRID_ROWS 20

@interface HWDTrainerVC ()
{
    NSMutableDictionary *trainedset;
}

@property (weak, nonatomic) IBOutlet UITextField *letter;

@end

@implementation HWDTrainerVC

- (void) match
{
    SSLine * lastLine = (SSLine *) [self.graph lastShape];
    if (!lastLine || [trainedset count]==0 || [lastLine count] == 0)
    {
        return;
    }
    
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
                NSLog(@"This line should be removed %@", [line toDictionary]);
            }
            else if(diff < keySimilarity)
            {
                bestGuess = key;
                keySimilarity = diff;
                //NSLog(@"ratio %f %f", [lastLine aspectRatio], [line aspectRatio]);
            }
        }
    }
    self.suggest.text = [NSString stringWithFormat:@"Suggested: %f", keySimilarity];
    self.letter.text = bestGuess;
}

- (IBAction)exportTrainingData
{
    NSLog(@"%@", [self toJson]);
}

- (IBAction)clearCanvas:(id)sender
{
   //
}

- (IBAction)saveLettter:(id)sender
{
    [self learn];
    [self clearCanvas:sender];
}

- (void) saveTrainingSet
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* cachesDir = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSString *jsonFileName = [[[cachesDir objectAtIndex:0] URLByAppendingPathComponent:JSON_TRANAING_SET_NAME_ENG] path];
    NSData *jsonBinary = [[self toJson] dataUsingEncoding:NSUTF8StringEncoding ];
    [jsonBinary writeToFile:jsonFileName atomically:NO];
    NSLog(@"Training set has been saved at %@", jsonFileName);
}

- (void) loadTrainingSet
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [trainedset removeAllObjects];
    NSArray* cachesDir = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSString *jsonFileName = [[[cachesDir objectAtIndex:0] URLByAppendingPathComponent:JSON_TRANAING_SET_NAME_ENG] path];
    NSData *jsonBinary = [NSData dataWithContentsOfFile:jsonFileName];
    if (jsonBinary == nil) {
        return;
    }
    NSMutableDictionary *savedTraineSet = [NSJSONSerialization JSONObjectWithData:jsonBinary options:NSJSONReadingMutableContainers error:nil];
    //TODO to recreate trainset
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

- (void)learn
{
    if(self.letter.text ==nil || [self.letter.text length]==0)
    {
        return; //nothing to learn for
    }
    //each leater is going to have more than one line
    NSMutableArray *learnt = [trainedset objectForKey: self.letter.text];
    if (!learnt)
    {
        learnt = [[NSMutableArray alloc]init];
    }
    [learnt addObject:[self.graph lastShape]];
    [trainedset setObject:learnt forKey:self.letter.text];
    [self saveTrainingSet];
}


- (void) didRefresh:(SSDrawableView *) glView
{
    [self match];
}

- (NSString *) toJson
{
    NSMutableString *linePointsJson = [[NSMutableString alloc]init];
    [linePointsJson appendString:@"{"];
    
    for (NSString *key in [trainedset allKeys])
    {
        [linePointsJson appendFormat:@"\"%@\":[", key];
        NSArray *lines = [trainedset objectForKey:key];
        for (SSLine *line in lines)
        {
            [linePointsJson appendFormat:@"%@", [line toDictionary]];
            if (![line isEqual:lines.lastObject])
            {
                [linePointsJson appendString:@","];
            }
        }
        [linePointsJson appendString:@"]"];
        if (![key isEqualToString:[trainedset allKeys].lastObject])
        {
            [linePointsJson appendString:@","];
        }
    }
    [linePointsJson appendString:@"}"];
    return linePointsJson;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    trainedset = [[NSMutableDictionary alloc]init];
    [self loadTrainingSet];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.title = @"Training";
    //self.glView.glViewDelegate = self;
}

- (void)viewDidUnload
{
    [self setSimilarity:nil];
    [self setLetter:nil];
    [self setSuggest:nil];
    [self setStokes:nil];
    [super viewDidUnload];
}

- (IBAction)clearTrainingSet:(id)sender
{
    
    [trainedset removeAllObjects];
    [self saveTrainingSet];
}

@end
