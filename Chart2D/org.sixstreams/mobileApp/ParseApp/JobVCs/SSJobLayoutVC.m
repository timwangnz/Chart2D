//
//  SSJobLayoutVC.m
//  SixStreams
//
//  Created by Anping Wang on 6/25/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSJobLayoutVC.h"
#import "SSHighlightsVC.h"
#import "SSSpotlightView.h"
#import "SSJobEditorVC.h"
#import "SSCompanyEditorVC.h"
#import "SSApp.h"

@interface SSJobLayoutVC ()<SSSpotlightViewDelegate>
{
    UIViewController *contentVC;
    id selectedView;
    SSEntityEditorVC *entitytEditor;
    NSString *selectedEntityType;
}

@end

@implementation SSJobLayoutVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil ? nibNameOrNil : @"SSLayoutVC" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) view:(SSSpotlightView *) view didSelect:(id) event
{
    if (selectedView == view)
    {
        return;
    }
    selectedView = view;
    if (!entitytEditor)
    {
        entitytEditor = [[SSApp instance]entityVCFor:view.entityType];
        entitytEditor.view.frame = CGRectMake(0, 0, entitytEditor.view.frame.size.width, entitytEditor.view.frame.size.height);
        UINavigationController *navCtrl = [[UINavigationController alloc]initWithRootViewController:entitytEditor];
        navCtrl.view.frame = entitytEditor.view.frame;
        [self showDetails:navCtrl];
        
    }
    entitytEditor.readonly = YES;
    entitytEditor.item2Edit = view.entity;
    [entitytEditor uiWillUpdate:view.entity];
    [entitytEditor.navigationController.view setNeedsLayout];
    [entitytEditor.navigationController.view layoutIfNeeded];
}

- (void) entityChanged
{
    self.title = [self.entity objectForKey:NAME];
    if([self.title isEqualToString:selectedEntityType])
    {
        return;
    }
    self.columns = 5;
    entitytEditor = nil;
    
    if ([self.title isEqual:@"Browse"])
    {
        SSHighlightsVC *highlightsVC =[[SSHighlightsVC alloc]init];
        highlightsVC.objectType = JOB_CLASS;
        contentVC = highlightsVC;
        [highlightsVC refreshOnSuccess:^(id data) {
            for(SSSpotlightView* view in [highlightsVC getItemViews])
            {
                [self addIconView:view];
                view.delegate = self;
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 140, view.frame.size.height);
                [view refreshUI];
            }
            [self doLayout];
        } onFailure:^(NSError *error) {
            //
        }];
    }
    
    if ([self.title isEqual:@"Companies"])
    {
        SSHighlightsVC *highlightsVC =[[SSHighlightsVC alloc]init];
        highlightsVC.objectType = COMPANY_CLASS;
        contentVC = highlightsVC;
        [self addChildViewController:highlightsVC];
        [highlightsVC refreshOnSuccess:^(id data) {
            for(SSSpotlightView *view in [highlightsVC getItemViews])
            {
                [self addIconView:view];
                view.delegate = self;
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 140, view.frame.size.height);
                [view refreshUI];

            }
            [self doLayout];
        } onFailure:^(NSError *error) {
            //
        }];
    }
    
    if ([self.title isEqual:@"People"])
    {
        SSHighlightsVC *highlightsVC =[[SSHighlightsVC alloc]init];
        highlightsVC.objectType = PROFILE_CLASS;
        contentVC = highlightsVC;
        [self addChildViewController:highlightsVC];
        [highlightsVC refreshOnSuccess:^(id data) {
            for(SSSpotlightView *view in [highlightsVC getItemViews])
            {
                [self addIconView:view];
                view.delegate = self;
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, 140, view.frame.size.height);
                [view refreshUI];
                
            }
            [self doLayout];
        } onFailure:^(NSError *error) {
            //
        }];
    }
    selectedEntityType = self.title;
}

@end
