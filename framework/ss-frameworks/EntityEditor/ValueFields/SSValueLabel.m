//
//  SSvalueLabel.m
//  SixStreams
//
//  Created by Anping Wang on 5/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSValueLabel.h"
#import "SSJSONUtil.h"
#import "SSApp.h"
@interface SSValueLabel()
{

}

@end

@implementation SSValueLabel

- (void) setText:(NSString *)text
{
    //value can be stored as id:value:type
    NSArray *comp = [text componentsSeparatedByString:@":"];
    if ([comp count]>1)
    {
        [super setText: [comp objectAtIndex:1]];
    }
    else
    {
        if ([self.metaType isEqualToString:@"phone"])
        {
            [super setText:[text toPhoneNumber]];
        }
        else
        {
            [super setText:text];
        }
    }
}


@end
