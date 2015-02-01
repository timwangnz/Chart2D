//
//  SSActivityView.m
//  SixStreams
//
//  Created by Anping Wang on 4/9/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSActivityView.h"
#import "SSCommentsVC.h"
#import "SSImageView.h"
#import "SSApp.h"

@interface SSActivityView ()
{
    __weak IBOutlet SSImageView *ivIcon;
    __weak IBOutlet UILabel *lObject;
    __weak IBOutlet UILabel *lSummary;
    __weak IBOutlet UILabel *lActor;
}
@end

@implementation SSActivityView

- (void) setActivity:(id)activity
{
    _activity = activity;
    NSString *jobTitle = [[[SSApp instance] getLov:JOB_TYPE ofType:@"job"] objectForKey:[self.activity objectForKey:@"subject"]];
    lSummary.text = [NSString stringWithFormat:@"%@", jobTitle];
    lActor.text = [NSString stringWithFormat:@"%@ %@ job", [self.activity objectForKey:USER], [self.activity objectForKey:@"type"]];
    ivIcon.url = [self.activity objectForKey:AUTHOR];
    ivIcon.cornerRadius = 4;
    lObject.text = [NSString stringWithFormat:@"%@ ago", [[self.activity objectForKey:CREATED_AT] since]];
}
@end
