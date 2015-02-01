//
//  SSResumeVC.m
//  JobsExchange
//
//  Created by Anping Wang on 2/8/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSResumeVC.h"
#import "SSSkillSetTW.h"
#import "SSExperienceTW.h"
#import "SSEducationTW.h"
#import "SSDateTextField.h"
#import "SSJSONUtil.h"
#import "SSEntityEditorVC.h"
#import "SSJobApp.h"
#import "SSValueField.h"
#import "SSAddressField.h"
#import "SSProfileVC.h"
#import "SSLovTextField.h"
#import "SSRoundTextView.h"
#import "SSSecurityVC.h"

@interface SSResumeVC ()<SSListOfValueFieldDelegate>
{
    IBOutlet UIView *vNames;
    IBOutlet UIView *vFooter;
    IBOutlet UIView *vAboutMe;
    IBOutlet SSExperienceTW *tvExperience;
    IBOutlet SSSkillSetTW *tvSkillSet;
    IBOutlet SSEducationTW *tvEducation;
    IBOutlet SSDateTextField *tfDateAvailable;
    BOOL published;
}

@end

@implementation SSResumeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Resume", @"Resumes");
        self.tabBarItem.image = [UIImage imageNamed:@"userx2"];
    }
    return self;
}

- (void) entityWillSave :(id)item
{
    [item setValue:self.profileId forKey:USER_ID];
}

- (void) entityDidSave :(id) item
{
    [SSSecurityVC invalidateCachedProfile];
    //
}

- (void) updateReadonly
{
    [tvSkillSet setEditable:!self.readonly];
    [tvEducation setEditable:!self.readonly];
    [tvExperience setEditable:!self.readonly];
}

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    tfDateAvailable.mode = UIDatePickerModeDate;
    if (entity)
    {
        [self updateReadonly];
        tvSkillSet.item = tvEducation.item = tvExperience.item = self.item2Edit;
        published = [[entity objectForKey:PUBLISHED]boolValue];
        [layoutTable removeChildViews];
        [layoutTable addChildView:vNames at:1];
        [layoutTable addChildView:vAboutMe at:2];
        [layoutTable addChildView:tvExperience at:3];
        [layoutTable addChildView:tvEducation at:4];
        [layoutTable addChildView:tvSkillSet at:5];
        layoutTable.flow = !self.readonly && self.isCreating;
        if (!layoutTable.flow)
        {
             [layoutTable addChildView:vFooter at:7];
        }
        [self linkEditFields];
        [layoutTable reloadData];
    }
}

- (void) listField:(id) listfield didAdd:(id) item
{
    [layoutTable reloadData];
}

- (void) listField:(id) listfield didDelete:(id) item
{
    [layoutTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.itemType = RESUME_CLASS;
    layoutTable.flow = NO;
}

@end
