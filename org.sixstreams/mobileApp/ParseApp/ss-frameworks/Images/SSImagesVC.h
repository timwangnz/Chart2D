//
//  SSImagesVC.h
//  SixStreams
//
//  Created by Anping Wang on 12/28/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSTableViewVC.h"


@interface SSImagesVC : SSTableViewVC

@property (weak, nonatomic) IBOutlet NSString *relatedType;
@property (weak, nonatomic) IBOutlet NSString *relatedId;
@property (weak, nonatomic) IBOutlet NSString *desc;
@property (nonatomic) BOOL singlePicture;

- (void) startAnimation;
- (void) stopAnimation;

@end
