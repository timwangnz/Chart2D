//
//  SSAddressField.m
//  Medistory
//
//  Created by Anping Wang on 11/9/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSAddressField.h"
#import "SSAddress.h"
#import "SSAddressVC.h"

@implementation SSAddressField

- (UIViewController *) getCandidateVC
{
    SSAddressVC *addressEditor = [[SSAddressVC alloc]initWithValueField:self];
    addressEditor.title = [self.attrName capitalizedString];
    addressEditor.field = self;
    return addressEditor;
}

- (void) processValue:  (id)value
{
    [super processValue:value];
    SSAddress *address = [[SSAddress alloc]initWithDictionary:value];
    self.text = [NSString stringWithFormat:@"%@", address];
}

@end
