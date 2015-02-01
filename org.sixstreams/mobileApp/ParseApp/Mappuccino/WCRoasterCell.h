//
//  WCRoasterCell.h
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/5/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSImageView.h"

@interface WCRoasterCell : UITableViewCell
{
    IBOutlet SSImageView *iconView;
    IBOutlet UILabel *name;
    IBOutlet UILabel *location;
}

- (void) configCell :(NSDictionary *) item;
@end
