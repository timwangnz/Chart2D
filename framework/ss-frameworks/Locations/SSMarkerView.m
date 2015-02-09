//
//  WCMarkerView.m
//  3rdWaveCoffee
//
//  Created by Anping Wang on 10/13/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSMarkerView.h"

@implementation SSMarkerView
@synthesize name, address;

- (void) setLocaton:(id) location;
{
    name.text = [location objectForKey:@"name"];
    address.text = [location objectForKey:@"address"];
}

@end
