//
//  WCMarkerView.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/13/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "WCMarkerView.h"

@implementation WCMarkerView
@synthesize name, address;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setRoaster:(id) roaster
{
    name.text = [roaster objectForKey:@"name"];
    address.text = [roaster objectForKey:@"address"];
}

@end
