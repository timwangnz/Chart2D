//
//  SSPictureCell.m
//  Mappuccino
//
//  Created by Anping Wang on 4/13/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import "SSPictureCell.h"

@implementation SSPictureCell

- (void) configUI:(id) image editable:(BOOL) editable
{
    picture.url = [image objectForKey:@"contentUrl"];
    caption.text = [image objectForKey:@"name"];
    if ([caption.text isEqualToString:@"No Caption"])
    {
        caption.hidden = YES;
    }
    like.customObject = image;
    del.customObject = image;
    like.hidden = !editable;
    del.hidden = !editable;
}

@end
