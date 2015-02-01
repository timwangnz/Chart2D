//
//  WCRoasterCell.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/5/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCRoasterCell.h"
#import "SSCommonVC.h"

@implementation WCRoasterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) configCell :(NSDictionary *) item
{
    name.text = [item objectForKey:@"name"];
    id address = [item objectForKey:@"address"];
    iconView.cornerRadius = 4;
    location.text = [NSString stringWithFormat:@"%@, %@, %@", [address objectForKey:@"street"], [address objectForKey:@"city"], [address objectForKey:@"state"]];
    iconView.url = [item objectForKey:REF_ID_NAME];
}

@end
