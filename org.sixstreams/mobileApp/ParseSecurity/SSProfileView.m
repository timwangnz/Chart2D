//
//  SSProfileView.m
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSProfileView.h"
#import "SSCommonVC.h"
#import "SSApp.h"

@implementation SSProfileView

- (void) setProfile:(id)profile
{
    _profile = profile;
    [self updateView];
}
- (void) updateView
{
    //get lov
    NSString *titleKey = [self.profile objectForKey: JOB_TITLE];
    lTitle.text = [[[SSApp instance] getLov:JOB_TITLE ofType:PROFILE_CLASS] objectForKey:titleKey];
    lNote.text = [NSString stringWithFormat:@"%@", [self.profile objectForKey: ABOUT_ME] ? [self.profile objectForKey: ABOUT_ME] : @""];
    
    NSString *groups = [self.profile objectForKey: GROUP];
    lGroup.text = [[[SSApp instance] getLov:GROUP ofType:PROFILE_CLASS] objectForKey:groups];
    ivProfile.url = [self.profile objectForKey:REF_ID_NAME];
    ivProfile.cornerRadius = 6;
    lEmail.text = [NSString stringWithFormat:@"%@", [self.profile objectForKey: EMAIL]];
    if ([self.profile objectForKey:FIRST_NAME])
    {
        lName.text = [NSString stringWithFormat:@"%@ %@", [self.profile objectForKey:FIRST_NAME], [self.profile objectForKey:LAST_NAME]];
    }
    else{
        lName.text = [NSString stringWithFormat:@"%@", [self.profile objectForKey:NAME]];
    }
}

@end
