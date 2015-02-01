//
//  SSApplicationVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/3/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSJobApplicationVC.h"
#import "SSApp.h"
#import "SSProfileVC.h"
#import "SSJobEditorVC.h"
#import "SSSkillSetTW.h"
#import "SSFilter.h"

@interface SSJobApplicationVC ()<SSImageViewDelegate>
{
    IBOutlet UIView *applView;
    IBOutlet UIView *jobDetailsView;
    //IBOutlet UIView *headerView;
    IBOutlet UIView *vMultiMedia;
    IBOutlet SSSkillSetTW *vSkills;
    
    IBOutlet UIView *vMessage;
    IBOutlet UIView *vJobDetails;
    IBOutlet UIView *vReq;
    IBOutlet UIView *vHeader;
}
@end

@implementation SSJobApplicationVC

- (void) processVideo:(id) sender
{
    [self.item2Edit setObject:@"Y" forKey:@"video"];
    [self save];
}

- (void) entityWillSave:(id)object
{
    [object setValue:[SSProfileVC name] forKeyPath:APPLICANT];
    [object setValue:[SSProfileVC profileId] forKeyPath:APPLICANT_ID];
    
    NSString *jobId = [self.job objectForKey:REF_ID_NAME];
    NSString *jobTitle = [self value:self.job attrName:JOB_TITLE];
    
    [object setValue:jobId forKeyPath:JOB];
    [object setValue:[NSNumber numberWithBool:NO] forKey:PUBLISHED];
    [object setValue:jobTitle forKeyPath:JOB_TITLE];
    
    NSDictionary *jobDetails = @{JOB_TITLE:jobTitle,
                                 METRO_AREA:[self value:self.job attrName:METRO_AREA],
                                 PAY_RATE: [self value:self.job attrName:PAY_RATE],
                                 INDUSTRY:[self value:self.job attrName:INDUSTRY],
                                 USER_INFO:[self value:self.job attrName:USER_INFO],
                                 COMPANY:[self value:self.job attrName:COMPANY],
                                 REF_ID_NAME:jobId};
    
    [object setValue:jobDetails forKeyPath:JOB_DETAILS];
    //evaluation
    [object setValue:[NSNumber numberWithInt:4] forKey : SCORE];
}

- (void) layoutForm
{
    [self.item2Edit setObject:self.job forKey:JOB_DETAILS];
    
    self.title = [self value:self.job attrName:JOB_TITLE];
    
    [layoutTable removeChildViews];
    if(!self.readonly)
    {
        layoutTable.flow = YES;
        layoutTable.tableHeaderView = jobDetailsView;
    }
    else
    {
        if([self.item2Edit objectForKey:REF_ID_NAME] )
        {
            iconView.delegate = self;
            iconView.owner = [self.item2Edit objectForKey:USERNAME];
            iconView.url = [self.item2Edit objectForKey:REF_ID_NAME];
        }
    }
    
    [layoutTable addChildView:vMessage];
    [layoutTable addChildView:vReq];
    [layoutTable addChildView:vJobDetails];
    
    if ([vSkills.items count]>0)
    {
        [layoutTable addChildView:vSkills];
    }
    
    if(!self.readonly)
    {
        [layoutTable addChildView:vMultiMedia];
        [layoutTable addChildView:applView];
    }
    
    vSkills.allowCheck = YES;
    [vSkills setUserInteractionEnabled:YES];
    [self linkEditFields];
    if (self.readonly)
    {
        layoutTable.tableHeaderView = vHeader;
    }
    [layoutTable reloadData];
}

- (void) uiWillUpdate:(id)item
{
    [super uiWillUpdate:item];
    self.title = [[SSApp instance] value:self.item2Edit[JOB_DETAILS] forKey:JOB_TITLE];
    
    if (!self.job)
    {
        
        [self getData:@[[SSFilter on:OBJECT_ID
                                  op:EQ
                               value:[item objectForKey:JOB]]]
               ofType:JOB_CLASS
             callback:^(id data) {
                 if ([data count]>0)
                 {
                     self.job = [data objectAtIndex:0];
                     [self layoutForm];
                 }
             }];
    }
    else{
        [self layoutForm];
    }
}

- (void) imageView:(id)imageView didLoadImage:(id)image
{
    //layoutTable.tableHeaderView = headerView;
}
@end
