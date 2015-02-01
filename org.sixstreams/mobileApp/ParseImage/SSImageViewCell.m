//
//  SSImageViewCell.m
//  SixStreams
//
//  Created by Anping Wang on 12/28/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSImageViewCell.h"
#import "SSImageView.h"

@interface SSImageViewCell()
{
    __weak IBOutlet SSImageView *imageView1;
    __weak IBOutlet SSImageView *imageView2;
    __weak SSImageView *currentview;
    NSString *currentFileId;
}

@end;

@implementation SSImageViewCell

- (void) changeView:(UIImage *) image
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView transitionWithView:self
                          duration:1.0f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            imageView1.image = image;
                        } completion:^(BOOL finished) {
                            
                        }];
    }];
}

- (void) changeFile:(id)fileId
{
    if (!currentFileId || ![currentFileId isEqualToString:fileId])
    {
        currentFileId = fileId;
        imageView1.url = currentFileId;
    }
}

@end
