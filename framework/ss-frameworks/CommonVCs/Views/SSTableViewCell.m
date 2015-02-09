//
//  SSTableViewCell.m
//  Medistory
//
//  Created by Anping Wang on 11/8/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableViewCell.h"
#import "SixStreams.h"

@implementation SSTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.icon.cornerRadius = 2;
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
     self.icon.cornerRadius = 2;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) assign:(id) item
{
    self.title.text = [item objectForKey:TITLE];
    
}

@end
