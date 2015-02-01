//
//  SSReferenceTextField.m
//  SixStreams
//
//  Created by Anping Wang on 1/1/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSReferenceTextField.h"
#import "SSReferenceEditorVC.h"

@interface SSReferenceTextField()
{
    SSReferenceEditorVC *refVC;
}

@end

@implementation SSReferenceTextField


- (void) processValue:  (id)value
{
    [super processValue:value];
    self.text = value;
}

- (NSString *) cellText: (id)rowItem atCol:(int) col
{
    return [rowItem objectForKey:NAME];
}

- (void) listOfValues:(id) tableView didSelect : (id) entity
{
    self.value = [entity objectForKey:NAME];
}

- (UIViewController *) getCandidateVC
{
    refVC = [[SSReferenceEditorVC alloc]init];
    refVC.fieldEditor = self;
    return refVC;
}

@end
