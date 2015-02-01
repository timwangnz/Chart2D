//
//  SSSkillEditor.m
//  SixStreams
//
//  Created by Anping Wang on 6/4/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSkillEditor.h"

@interface SSSkillEditor ()

@end

@implementation SSSkillEditor

- (void) entityDidSave:(id)object
{
    [self showAlert:@"Skill is saved" withTitle:@"Wohoo"];
}
@end
