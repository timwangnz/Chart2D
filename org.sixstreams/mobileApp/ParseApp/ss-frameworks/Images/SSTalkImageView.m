//
//  SSTalkImageView.m
//  Mappuccino
//
//  Created by Anping Wang on 4/26/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSTalkImageView.h"
#import "SSStorageManager.h"

@interface SSTalkImageView()
{
    UIButton *record, *play;
}
@end;

@implementation SSTalkImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (UIButton *) addButton:(NSString *) label action: (SEL)action
{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, self.frame.size.height - 50, 60, 40)];
    [btn setTitle:label forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.backgroundColor = [UIColor darkGrayColor];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn];
    return btn;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self addTap];
    [self initRecorder];
    
    record = [self addButton:@"Record" action:@selector(recordAudio)];
    play = [self addButton:@"Play" action:@selector(playAudio)];
    
    play.frame = CGRectMake((self.frame.size.width - 80), self.frame.size.height - 50, 60, 40);
}


-(IBAction) recordAudio
{
    if (!audioRecorder.recording)
    {
        [audioRecorder record];
        record.backgroundColor = [UIColor redColor];
    }
    else{
        [audioRecorder stop];
        
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    play.backgroundColor = [UIColor darkGrayColor];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [[SSStorageManager storageManager]saveContent:[NSData dataWithContentsOfURL:recorder.url]
                                               uri:[NSString stringWithFormat:@"%@/%@", self.url, @"sound.caf"]];
 
    DebugLog(@"%@", [NSString stringWithFormat:@"%@/%@", self.url, @"sound.caf"]);
    record.backgroundColor = [UIColor darkGrayColor];
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    
}

-(IBAction) playAudio
{
    if(audioPlayer && audioPlayer.playing)
    {
        [audioPlayer stop];
    }
    else if (!audioRecorder.recording)
    {
        NSError *error;
        NSData *data = [[SSStorageManager storageManager]readContent:[NSString stringWithFormat:@"%@/%@", self.url, @"sound.caf"]];
        audioPlayer = [[AVAudioPlayer alloc]
                       initWithData:data
                       error:&error];
        
        play.backgroundColor = [UIColor redColor];
        audioPlayer.delegate = self;
        
        if (error)
        {
            DebugLog(@"Error: %@", [error localizedDescription]);
        }
        else
        {
            [audioPlayer play];
        }
    }
}

- (void)imageTapped:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.25
                     animations:^(void){
                         gestureRecognizer.view.alpha = 0.25f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.25 animations:^(void){
                             gestureRecognizer.view.alpha = 1.0f;
                         }
                                          completion:^(BOOL finished) {
                                              
                                              
                                          }
                          ];
                     }];
}


- (void) initRecorder
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:1000.0], AVSampleRateKey,
                                   // [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    nil];
    
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    audioRecorder.delegate = self;
    if (error)
    {
        DebugLog(@"error: %@", [error localizedDescription]);
        
    } else
    {
        [audioRecorder prepareToRecord];
    }
}

- (void) addTap
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:singleTap];
    [self setUserInteractionEnabled:YES];
}

@end
