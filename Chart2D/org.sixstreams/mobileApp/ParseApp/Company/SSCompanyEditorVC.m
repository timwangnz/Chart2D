//
//  SSCompanyVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCompanyEditorVC.h"
#import "SSValueField.h"
#import "SSLovTextField.h"
#import "SSApp.h"
#import "SSCompanyVC.h"
#import "SSProfileVC.h"
#import "SSFilter.h"

@interface SSCompanyEditorVC ()
{
    IBOutlet UIView *edContact;
    IBOutlet UIView *edProfile;
    IBOutlet UIView *edDetails;
    IBOutlet UIView *edProfileView;
    IBOutlet UIView *edAbout;
    IBOutlet UIView *edFooter;
}
@end

@implementation SSCompanyEditorVC

- (void) uiWillUpdate:(id)entity
{
    [super uiWillUpdate:entity];
    self.itemType = COMPANY_CLASS;
    [self doLayout];
}

- (void) doLayout
{
    [layoutTable removeChildViews];
    if ([[self.item2Edit allKeys]count]!=0)
    {
        [layoutTable addChildView:edProfileView];
    }
    layoutTable.flow = !self.readonly && self.isCreating;
    [layoutTable addChildView:edProfile];
    [layoutTable addChildView:edContact];
    [layoutTable addChildView:edDetails];
    [layoutTable addChildView:edAbout];
   
    [super doLayout];
    [layoutTable addChildView: [self addLayoutButton : @"People" onTap:@selector(showPeople)]];
    [layoutTable addChildView: [self addLayoutButton : @"Jobs" onTap:@selector(showJobs:)]];
   
    if (!layoutTable.flow )
    {
        [layoutTable addChildView:edFooter];
    }
    
    [self linkEditFields];
    [layoutTable reloadData];
}

- (void) showPeople
{
    SSProfileVC *profileVC = [[SSProfileVC alloc]init];
    [profileVC.predicates addObject:[SSFilter on:COMPANY op:EQ value: [self.item2Edit objectForKey:REF_ID_NAME]]];
    profileVC.title = [NSString stringWithFormat:@"People at %@", self.item2Edit[NAME]];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void) showJobs:(id) sender
{
    SSSearchVC *jobs = [[SSSearchVC alloc]init];
    jobs.objectType = JOB_CLASS;
    jobs.addable = NO;
    jobs.editable = NO;
    
    jobs.titleKey = JOB_TITLE;
    jobs.subtitleKey = COMPANY;
    
    jobs.entityEditorClass = @"SSJobEditorVC";
    jobs.title = [NSString stringWithFormat:@"Jobs at %@", self.item2Edit[NAME]];
    
    [jobs.predicates addObject:[SSFilter on:COMPANY op:EQ value:self.item2Edit[REF_ID_NAME]]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:jobs animated:YES];
}

- (SSSearchVC *) createSearchVC
{
    SSCompanyVC *search = [[SSCompanyVC alloc]init];
    search.objectType = self.itemType;
    search.entityEditorClass = [[SSApp instance] editorClassFor:search.objectType];
    return search;
}

@end
