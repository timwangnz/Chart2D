//
//  SSProfile4JobVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSProfile4JobVC.h"
#import "SSResumeVC.h"
#import "SSSearchVC.h"
#import "SSFilter.h"
#import "SSProfileVC.h"

@interface SSProfile4JobVC ()<SSEntityEditorDelegate>

@end

@implementation SSProfile4JobVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil ? nibNameOrNil : @"SSProfileEditorVC" bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(JOBS,  JOBS);
        self.tabBarItem.image = [UIImage imageNamed:@"jobx2"];
        self.itemType = PROFILE_CLASS;
    }
    return self;
}

- (void) viewResume: (id) sender
{
    [[SSConnection connector] objectsOfType:RESUME_CLASS
                                   authorId:[self profileId]
                                  onSuccess:^(id data) {
        NSArray *resumes = [data objectForKey:PAYLOAD];
        if ([resumes count] > 0)
        {
            SSResumeVC *resumeVC = [[SSResumeVC alloc]init];
            [self addChildViewController:resumeVC];
            resumeVC.item2Edit = [resumes objectAtIndex:0];
            resumeVC.readonly = YES;
            [self.navigationController pushViewController:resumeVC animated:YES];
        }
        else
        {
            if(self.isAuthor && !self.readonly)
            {
                SSResumeVC *resumeVC = [[SSResumeVC alloc]init];
                resumeVC.entityEditorDelegate = self;
                [self.navigationController pushViewController:resumeVC animated:YES];
            }
        }
    } onFailure:^(NSError *error) {
        
    }];
}

- (void) showApplications:(id) sender
{
    SSSearchVC *applications = [[SSSearchVC alloc]init];
    applications.objectType = JOB_APPLICATION_CLASS;
    applications.addable = NO;
    applications.defaultHeight = 55;
    applications.editable = YES;
    applications.titleKey = JOB_TITLE;
    applications.subtitleKey = STATUS;
    applications.entityEditorClass = @"SSJobApplicationVC";
    applications.title = @"Applications";
    //only application for this user
    [applications.predicates addObject:[SSFilter on:APPLICANT_ID op:EQ value:self.item2Edit[REF_ID_NAME]]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];

    [applications refreshOnSuccess:^(id data) {
        [self.navigationController pushViewController:applications animated:YES];
    } onFailure:^(NSError *error) {
        //
    }];
    
}

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    BOOL hasResume = [self.item2Edit[RESUME] isEqualToString:@"Y"];
    
    if (self.readonly)
    {
        [layoutTable addChildView: [self addLayoutButton : @"My Applications" onTap:@selector(showApplications:)] at: 4];
        
    }
    else if(self.isAuthor)
    {
        [layoutTable addChildView: [self addLayoutButton : [NSString stringWithFormat: @"%@ Resume", hasResume ? @"Edit" : @"Add"]
                                                   onTap : @selector(viewResume:)]
                               at: 4];
    }
}

@end
