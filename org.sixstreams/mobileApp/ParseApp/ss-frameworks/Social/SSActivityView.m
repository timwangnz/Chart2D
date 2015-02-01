//
//  SSActivityView.m
//  SixStreams
//
//  Created by Anping Wang on 4/9/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSActivityView.h"

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
 
    NSString *subject = [self.activity objectForKey:@"subject"];
    
    lSummary.text = [[SSApp instance] contextForActiviy:activity onSubject:subject];
    id userInfo = [self.activity objectForKey:USER_INFO];
    lActor.text = [NSString stringWithFormat:@"%@ %@ %@", [userInfo objectForKey:NAME],
                   [self.activity objectForKey:@"action"],  subject];
    ivIcon.url = [self.activity objectForKey:AUTHOR];
    ivIcon.cornerRadius = 4;
    lObject.text = [NSString stringWithFormat:@"%@ ago", [[self.activity objectForKey:CREATED_AT] since]];
}
@end
