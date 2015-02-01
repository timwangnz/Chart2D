//
//  SSProfileView.h
//  Medistory
//
//  Created by Anping Wang on 10/26/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSImageView.h"

@interface SSProfileView : UIView
{
    IBOutlet UILabel *lName;
    IBOutlet UILabel *lTitle;
    IBOutlet UILabel *lEmail;
    IBOutlet UILabel *lGroup;
    IBOutlet UITextView *lNote;
    IBOutlet SSImageView *ivProfile;
}

- (void) updateView;
@property (nonatomic, strong) id profile;

@end
