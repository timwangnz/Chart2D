//
//  SSWordView.m
//  SixStreams
//
//  Created by Anping Wang on 1/3/15.
//  Copyright (c) 2015 SixStream. All rights reserved.
//

#import "SSWordView.h"
#import "HTTPConnector.h"

@implementation SSWordView

- (void) setValue: word
{
    self.word.text = word[@"word"];
    self.type.text = word[@"type"];
    self.sample.text = word[@"sample"];
    self.meaning.text = word[@"meaning"];
}


@end
