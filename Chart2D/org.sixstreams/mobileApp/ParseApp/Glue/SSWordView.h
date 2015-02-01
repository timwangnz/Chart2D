//
//  SSWordView.h
//  SixStreams
//
//  Created by Anping Wang on 1/3/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSImageView.h"

@interface SSWordView : SSImageView

@property (weak, nonatomic) IBOutlet UILabel *word;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *sample;
@property (weak, nonatomic) IBOutlet UILabel *meaning;


- (void) setValue: word;
@end
