//
//  SSCreateJobVC.m
//  JobsExchange
//
//  Created by Anping Wang on 3/10/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSJobEditorVC.h"
#import "SSLovTextField.h"
#import "SSJobApp.h"
#import "SSValueField.h"
#import "SSRoundTextView.h"
#import "SSSkillSetTW.h"
#import "SSJSONUtil.h"
#import "SSProfileVC.h"
#import "SSProfileView.h"
#import "SSJobApplicationVC.h"
#import "SSFilter.h"
#import "SSResumeVC.h"

@interface SSJobEditorVC ()<UITextFieldDelegate, UIDocumentInteractionControllerDelegate, SSImageViewDelegate, SSTableViewVCDelegate>
{
    IBOutlet UILabel *lSectionHeader;
    IBOutlet UIView *vControl;
    IBOutlet UILabel *lHelpPicture;
    IBOutlet UIView *vHeader;
    IBOutlet UIButton *btnPickImg;
    IBOutlet UIButton *btnFindSimilarJobs;
    IBOutlet UIView *vRequirement;
    IBOutlet SSProfileView *vRecruiter;
    IBOutlet UIView *jobReqView;
    IBOutlet UIView *summaryView;
    IBOutlet UIView *jobView;
    IBOutlet UIView *footerView;
    IBOutlet UIView *actionView;
    
    IBOutlet SSRoundTextView *jobSummary;
    IBOutlet SSSkillSetTW *tvSkillset;
    IBOutlet SSRoundTextView *companyDesc;
    
    UIDocumentInteractionController *documentController;
}

- (IBAction)applyForJob:(id)sender;

@end

@implementation SSJobEditorVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(JOBS,  JOBS);
        self.tabBarItem.image = [UIImage imageNamed:@"jobx2"];
        self.itemType = JOB_CLASS;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    tvSkillset.parentVC = self;
}

- (void) entityWillSave:(id)object
{
    id metro = object[METRO_AREA];
    if (metro)
    {
        id metroItem = [[SSApp instance] getLov:METRO_AREA ofType:JOB_CLASS][metro];
        object[LATITUDE] = [NSNumber numberWithFloat:[metroItem[LATITUDE]floatValue]];
        object[LONGITUDE] = [NSNumber numberWithFloat:[metroItem[LONGITUDE]floatValue]];
    }
}

//ui updates
- (void) uiWillUpdate:(id)item
{
    [super uiWillUpdate:item];
    self.title = [[SSApp instance] value:item forKey:JOB_TITLE];
    layoutTable.flow = !self.readonly && self.isCreating;
    
    btnFindSimilarJobs.hidden = !self.readonly;
    BOOL isMyJob = [self.item2Edit[USER_INFO][REF_ID_NAME] isEqualToString:[SSProfileVC profileId]];
    lHelpPicture.hidden = self.readonly;
    
    if([self.item2Edit objectForKey:REF_ID_NAME])
    {
        iconView.delegate = self;
        iconView.owner = self.item2Edit[USERNAME];
        iconView.url = self.item2Edit[REF_ID_NAME];
    }
    else
    {
        if (!self.readonly && !layoutTable.flow)
        {
            layoutTable.tableHeaderView = vHeader;
        }
    }
    [layoutTable removeChildViews];
    [layoutTable addChildView:summaryView];
    if (!self.readonly)
    {
         [layoutTable addChildView:vControl];
    }
    
    [layoutTable addChildView:jobView];
    [layoutTable addChildView:jobReqView];
    
    if (jobSummary.editable || (jobSummary.text && [jobSummary.text length] > 0)) {
        [layoutTable addChildView:vRequirement];
    }
    
    tvSkillset.items = [item objectForKey:tvSkillset.attrName];

    if (!self.readonly || [tvSkillset.items count ] > 0)
    {
        [layoutTable addChildView:tvSkillset];
    }
    
    if (self.readonly) {
        if(!isMyJob)
        {
            [layoutTable addChildView:actionView at: 2];
            
             //check if I have alaready applied
            NSArray *filters = @[[SSFilter on:AUTHOR op:EQ value:[self profileId]],
                                [SSFilter on:JOB op:EQ value: [self.item2Edit objectForKey:REF_ID_NAME]]
                                ];
            [self getData:filters ofType:JOB_APPLICATION_CLASS callback:^(id data) {
                if ([data count] != 0)
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                        [layoutTable removeChildView:actionView];
                    }];
                }
            }];
           
        }
    }
    
    [super doLayout];
    
    if (self.readonly && isMyJob)
    {
        [layoutTable addChildView: lSectionHeader];
        [layoutTable addChildView: [self addLayoutButton : @"View Applicants" onTap:@selector(showApplications:)]];
        [layoutTable addChildView: [self addLayoutButton : @"Promote This Job" onTap:@selector(promote:)]];
        [layoutTable addChildView: [self addLayoutButton : @"Find Candidates" onTap:@selector(findCandidates:)]];
        [layoutTable addChildView: [self addLayoutButton : @"Delete This Job" onTap:@selector(deleteItem:)]];
    }
    
    if(!layoutTable.flow)
    {
        if(self.readonly)
        {
            [layoutTable addChildView:vRecruiter];
        }
        [layoutTable addChildView:footerView];
    }
    
    [self linkEditFields];
    [layoutTable reloadData];
    [layoutTable setNeedsLayout];
    [layoutTable layoutIfNeeded];
}

//actions

- (void) showApplications:(id) sender
{
    SSSearchVC *applications = [[SSSearchVC alloc]init];
    applications.objectType = JOB_APPLICATION_CLASS;
    applications.titleKey = APPLICANT;
    applications.entityEditorClass = @"SSApplicationEditorVC";
    applications.addable = NO;
    [applications.predicates addObject:[SSFilter on:JOB op:EQ value:self.item2Edit[REF_ID_NAME]]];
    [self.navigationController pushViewController:applications animated:YES];
}


- (void) findCandidates:(id) sender
{
    SSProfileVC *candidates = [[SSProfileVC alloc]init];
    candidates.objectType = PROFILE_CLASS;
    candidates.titleKey = FIRST_NAME;
    candidates.entityEditorClass = @"SSProfile4JobVC";
    candidates.addable = NO;
    //TODO get candidates criterions
    //[applications.predicates addObject:[SSFilter on:JOB op:EQ value:self.item2Edit[REF_ID_NAME]]];
    [self.navigationController pushViewController:candidates animated:YES];
}


- (void) promote:(id) sender
{
    BOOL promotable = self.item2Edit[PUBLISHED] && self.item2Edit[ICON];
    if (!promotable) {
        [self showAlert:@"Job is not published or does not have a profile picture, please correct and promote again" withTitle:@"Not promotable"];
        return;
    }
    //[self.item2Edit setObject:@"Y" forKey:SPOT_LIGHTS];
    self.item2Edit[SPOT_LIGHTS] = @"Y";
    [self save];
}

//delegates callbacks
- (void) listField:(id)listfield didAdd:(id)item
{
    [layoutTable reloadData];
}

- (void) listField:(id)listfield didDelete:(id)item
{
    [layoutTable reloadData];
}

- (void) imageView:(id) imageView didLoadImage:(id) image
{
    if (!layoutTable.flow && !layoutTable.tableHeaderView)
    {
        if(image != nil || !self.readonly)
        {
            [UIView animateWithDuration:0.5 animations:^{
                layoutTable.tableHeaderView = vHeader;
            }];
        }
    }
}

- (void) tableViewVC:(id) tableViewVC didLoad : (id) objects
{
    [layoutTable reloadData];
}

//end callbacks

//Apply for jobs
- (void) createResume:(id) sender
{
    SSResumeVC *resumeVC = [[SSResumeVC alloc] init];
    resumeVC.item2Edit = nil;
    resumeVC.itemType = RESUME_CLASS;
    [self showPopup:resumeVC sender:sender];
}

- (void) apply:(id) sender
{
    id object = [NSMutableDictionary dictionary];
    [object setValue:[SSProfileVC name] forKeyPath:APPLICANT];
    [object setValue:[SSProfileVC profileId] forKeyPath:APPLICANT_ID];
    NSString *jobId = [self.item2Edit objectForKey:REF_ID_NAME];
    [object setValue:jobId forKeyPath:JOB];
    [object setValue:self.title forKeyPath:JOB_TITLE];
    
    NSDictionary *jobDetails = [self.item2Edit subset:@[NAME, METRO_AREA, PAY_RATE, INDUSTRY, COMPANY, REF_ID_NAME]];
    
    [object setValue:jobDetails forKeyPath:JOB_DETAILS];
    [object setValue:@"Draft" forKeyPath:STATUS];
    
    SSJobApplicationVC *applicationVC = [[SSJobApplicationVC alloc] init];
    applicationVC.job = self.item2Edit;
    applicationVC.item2Edit = object;
    applicationVC.itemType = JOB_APPLICATION_CLASS;
    [self showPopup:applicationVC sender:sender];
}

- (IBAction)applyForJob:(id)sender
{
    if (![[[self profile] objectForKey:RESUME] isEqualToString:@"Y"]) {
        [self showAlert:@"Would you like to create one first?"
              withTitle:@"No Resume"
            cancelTitle:@"No"
                okTitle:@"Yes"
               onSelect:^(NSString *selectedTitle) {
                   if ([selectedTitle isEqualToString:@"No"])
                   {
                       [self apply:sender];
                   }
                   else{
                       [self createResume:sender];
                   }
               }];
    }
    else{
        [self apply:sender];
    }
}
//end apply for jobs


@end
