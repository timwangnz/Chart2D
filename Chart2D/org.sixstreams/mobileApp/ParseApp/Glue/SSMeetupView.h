//
//  SSMeetupView.h
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSImageView.h"

@interface SSMeetupView : UIView
{
    
    IBOutlet UILabel *lEventTitle;
    IBOutlet UILabel *lHost;
    IBOutlet UILabel *lEMail;
    IBOutlet UILabel *lJobTitle;
    IBOutlet UILabel *lGroup;
    IBOutlet UIImageView *ivFormat;

    IBOutlet SSImageView *organizerIcon;
}

@property (nonatomic, strong) id meet;

- (void) updateView;
- (UIImage *) getImage;

@end
