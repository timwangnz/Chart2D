//
//  SSMeetupView.m
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSMeetupView.h"
#import "SSCommonVC.h"
#import "SSAddress.h"
#import "SSTimeUtil.h"
#import "SSApp.h"
#import "SSConnection.h"
#import <Parse/Parse.h>
#import "SSEventVC.h"

@implementation SSMeetupView

- (void) updateView
{
    NSString *meetId = [self.meet objectForKey:MEETING_ID];
    if(meetId)
    {
        self.hidden = YES;
        [[SSConnection connector] objectForKey:meetId ofType:MEETING_CLASS onSuccess:^(id data) {
            self.meet = data;
            [self updateView];
            self.hidden = NO;
        } onFailure:^(NSError *error) {
            //
        }];
    }
    else
    {
        id data = self.meet;
        
        lEventTitle.text = [data objectForKey:TITLE];
        id organizer = [data objectForKey:ORGANIZER];
        ivFormat.image = [[SSApp instance] defaultImage:organizer ofType:USER_TYPE];
        lHost.text = [NSString stringWithFormat:@"%@ %@", [organizer objectForKey: FIRST_NAME],
                      [organizer objectForKey: LAST_NAME]
                      ];
        id lov = [[SSApp instance] getLov:GROUP ofType:PROFILE_CLASS] ;
        lJobTitle.text = [lov objectForKey: [organizer objectForKey:GROUP]];
       
    
        lEMail.text = [organizer objectForKey:EMAIL];
   
        
        organizerIcon.owner = [organizer objectForKey:USERNAME];
        organizerIcon.url = [organizer objectForKey:REF_ID_NAME];
    }
}



- (UIImage *) getImage
{
    return organizerIcon.image;
}

@end
