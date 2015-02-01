//
//  SSPictureCell.h
//  Mappuccino
//
//  Created by Anping Wang on 4/13/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellButton.h"
#import "SSImageView.h"

@interface SSPictureCell : UITableViewCell
{
    IBOutlet UILabel *caption;
    IBOutlet CellButton *like;
    IBOutlet CellButton *del;
    IBOutlet SSImageView *picture;
}

- (void) configUI:(id) image editable:(BOOL) editable;

@end
