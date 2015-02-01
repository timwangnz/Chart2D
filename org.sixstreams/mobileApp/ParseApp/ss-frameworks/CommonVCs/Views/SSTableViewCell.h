//
//  SSTableViewCell.h
//  Medistory
//
//  Created by Anping Wang on 11/8/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSImageView.h"

#define SSTableViewCellIdentifier @"SSTableViewCellIdentifier"

@interface SSTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet SSImageView *icon;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;

- (void) assign:(id) item;

@end
