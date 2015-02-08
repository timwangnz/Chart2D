//
//  SSMyGroupsVC.m
//  SixStreams
//
//  Created by Anping Wang on 7/30/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSMyGroupsVC.h"
#import "SSFilter.h"
#import "SSProfileVC.h"

@interface SSMyGroupsVC ()

@end

@implementation SSMyGroupsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleKey = GROUP_NAME;
    self.objectType = MEMBERSHIP_CLASS;
    self.iconKey = GROUP_ID;
    self.editable = NO;
    self.addable = NO;
    self.title = @"My Groups";
    [self.predicates addObject:[SSFilter on: USER_ID op:EQ value: [SSProfileVC profileId]]];
}

@end
