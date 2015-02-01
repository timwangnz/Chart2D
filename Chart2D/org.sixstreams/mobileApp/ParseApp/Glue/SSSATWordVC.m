//
//  SSSATWordVC.m
//  SixStreams
//
//  Created by Anping Wang on 12/30/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSATWordVC.h"

@interface SSSATWordVC ()

@end

@implementation SSSATWordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    [self linkEditFields];
}

+ (void) loadCSV
{
    NSError *error;
    NSString *sourceFileString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                                     pathForResource:@"SATWords" ofType:@"txt"]
                                                           encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsHebrew)
                                                              error:&error];
    
    NSArray *columns = @[@"word", @"type", @"meaning", @"sample", @"rate"];
    //NSLog(@"%@", columns);
    
    if (error)
    {
        NSLog(@"Failed to load SATWords.txt %@", error);
        return;

    }
    
    if(!sourceFileString)
    {
        NSLog(@"Failed to load SATWords.csv");
        return;
    }
    NSMutableArray *csvArray = [[NSMutableArray alloc] init];
    
    csvArray = [[sourceFileString componentsSeparatedByString:@"\r"] mutableCopy];
    SSSATWordVC *wordVC = [[SSSATWordVC alloc]init];
    
    for (int i = 0; i < [csvArray count]; i++) {
        NSMutableDictionary *word = [NSMutableDictionary dictionary];
        
        NSString *keysString = [csvArray objectAtIndex:i];
       
        //strip quotes
        NSArray *keysArray = [keysString componentsSeparatedByString:@"\t"];
        
        for (int j = 0; j < [keysArray count] && j < [columns count]; j++) {
            [word setObject: [keysArray[j] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:columns[j]];
            
        }
        wordVC.itemType = WORD_CLASS;
        wordVC.item2Edit = word;
        wordVC.valueChanged = YES;
        [wordVC doSave:nil];
    }
  
    [csvArray removeObjectAtIndex:0];
}
@end
