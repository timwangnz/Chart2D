//
//  SSHightlightsVC.m
//  SixStreams
//
//  Created by Anping Wang on 5/14/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSDeckViewVC.h"
#import "SSStorageManager.h"

#import "SSImageView.h"
#import "SSApp.h"
#import "SSFilter.h"
#import "SSDeckView.h"
#import "SSProfileEditorVC.h"
#import "SSProfileVC.h"
#import "SSShadowView.h"
#import "SSMenuVC.h"
#import "SSValueField.h"
#import "SSStorageManager.h"
#import "SSDeckHolderView.h"

@interface SSDeckViewVC ()<SSImageViewDelegate, SSEntityEditorDelegate, SSDeckViewDelegate, SSMenuVCDelegate>
{
    IBOutlet SSShadowView *pagesContainer;
    IBOutlet UILabel *noObjectsLabel;
    IBOutlet UIButton *clearHistoryBtn;
    IBOutlet UIView *headerView;
    IBOutlet UIView *highlightsView;
    
    IBOutlet SSDeckHolderView *deckViewContainer;
    
    
    IBOutlet UIButton *likeBtn;
    IBOutlet UIButton *dislikeBtn;
    
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *detailLabel;
    NSMutableArray *detailsViews;
    
    UIViewController *popupVC;
    BOOL loaded;
    UINavigationController *navCtrl;
    UIView *ctrlView;
    
    NSString *likeText;
    NSString *dislikeText;
    NSMutableArray *liked;
    NSMutableArray *disliked;

}

- (IBAction)showMenu:(UIButton *)sender;
- (IBAction)like:(UIButton *)sender;
- (IBAction)nope:(UIButton *)sender;

@end

@implementation SSDeckViewVC

- (IBAction)clearHistory:(id)sender
{
    [liked removeAllObjects];
    [disliked removeAllObjects];
    [self saveLocally];
    [self refreshOnSuccess:^(id data) {
        [self refreshUI];
    } onFailure:^(NSError *error) {
        [self showAlert:@"Please try later!" withTitle:@"Error"];
    }];
}

- (IBAction)like:(UIButton *)sender
{
    SSDeckView *view = [detailsViews lastObject];
    if ([detailsViews count] - 2 > 0)
    {
        SSDeckView *nextView = [detailsViews objectAtIndex:[detailsViews count] - 2];
        nextView.hidden = NO;
    }
    [view vote:YES];
}

- (IBAction)nope:(UIButton *)sender
{
    SSDeckView *view = [detailsViews lastObject];
    if ([detailsViews count] - 2 > 0)
    {
        SSDeckView *nextView = [detailsViews objectAtIndex:[detailsViews count] - 2];
        nextView.hidden = NO;
    }
    [view vote:NO];
}

- (void) view:(SSDeckView *)view didSwipeRight:(id)event
{
    if (![liked containsObject:view.entity[REF_ID_NAME]])
    {
        [liked addObject:view.entity[REF_ID_NAME]];
    }
    [view removeFromSuperview];
    [detailsViews removeLastObject];
    view.hidden = YES;
    
    [self saveLocally];
    [self refreshUI];
}

- (void) view:(SSDeckView *)view didSwipeLeft:(id)event
{
    if (![disliked containsObject:view.entity[REF_ID_NAME]])
    {
        [disliked addObject:view.entity[REF_ID_NAME]];
    }
    [view removeFromSuperview];
    [detailsViews removeLastObject];
    
    [self saveLocally];
    [self refreshUI];
}

- (void) saveLocally
{
    [[SSStorageManager storageManager] save:@{@"liked":liked, @"disliked":disliked} uri: @"com.sixstreams.deckview"];
}

- (void) loadLocally
{
    NSDictionary *saved = [[SSStorageManager storageManager] read:@"com.sixstreams.deckview"];
    liked = [NSMutableArray arrayWithArray:saved[@"liked"]];
    disliked = [NSMutableArray arrayWithArray:saved[@"disliked"]];
}

- (void) view:(SSDeckView *) view isMoving:(id) event
{
    NSUInteger i = [detailsViews indexOfObject:view];
    if (i > 0)
    {
        UIView *nextView = [detailsViews objectAtIndex:i-1];
        nextView.hidden = NO;
    }
}

- (IBAction)showMenu:(UIButton *)sender
{
    if (sender.tag == 10)
    {
        [UIView animateWithDuration:0.5 animations:^{
            if (self.view.frame.origin.x < 0)
            {
                self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
            else
            {
                self.view.frame = CGRectMake(-60, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if (sender.tag == 0)
    {
        [self showVC: [[SSApp instance] entityVCFor:SETTINGS]];
    }
    if (sender.tag == 1)
    {
        [self showVC: [[SSApp instance] entityVCFor:SEARCH]];
    }
    if (sender.tag == 2)
    {
        SSProfileEditorVC *vc = (SSProfileEditorVC*) [[SSApp instance] entityVCFor:PROFILE_CLASS];
        vc.item2Edit = [SSProfileVC profile];
        vc.itemType = PROFILE_CLASS;
        vc.readonly = YES;
        [self showVC: vc];
    }
    
    if (sender.tag == 3)
    {
        SSProfileVC *profiles = [[SSProfileVC alloc]init];
        profiles.title = @"People";
        profiles.tabBarItem.image = [UIImage imageNamed:@"people"];
        [self showVC: profiles];
    }
}

- (void) refreshUI
{
    [super refreshUI];
    
    if([detailsViews count]>0)
    {
        UIView *topview = [detailsViews lastObject];
        topview.hidden = NO;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        dislikeBtn.hidden = likeBtn.hidden = [detailsViews count] == 0;
        noObjectsLabel.hidden = clearHistoryBtn.hidden = !likeBtn.hidden;
    }];
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.title = [[SSApp instance] name];
    
    detailsViews=[NSMutableArray array];
    self.tabBarItem.image = [UIImage imageNamed:@"mind_map-32.png"];
    self.addable = NO;
    self.showBusyIndicator = NO;
    self.limit = 40;
    self.queryPrefixKey = TITLE;
    self.orderBy = CREATED_AT;
    self.ascending = NO;
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menuIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"filterIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFilters)];
    
    navCtrl = self.navigationController;
    
    likeText = @"Like";
    dislikeText = @"Nope";
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textForVote:)])
    {
        likeText = [self.delegate textForVote:YES];
        dislikeText = [self.delegate textForVote:NO];
    }
    [likeBtn setTitle:likeText forState:UIControlStateNormal];
    [dislikeBtn setTitle:dislikeText forState:UIControlStateNormal];
    [self.view addSubview: deckViewContainer];
    [self loadLocally];
    loaded = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[SSApp instance] initializeOnSuccess:^(id data) {
        if(!loaded)
        {
            [self refreshOnSuccess:^(id data) {
                self.navigationController.navigationBar.hidden = NO;
                loaded = YES;
                [self headview];
                [self refreshUI];
            } onFailure:^(NSError *error) {
                
            }];
        }
    }];
}

- (void) onDataReceived:(id) objects
{
    [super onDataReceived:objects];
    [self loadLocally];
    [self updateModel];
}

- (void) updateModel
{
    id objects = self.objects;
    
    if([objects count] == 0)
    {
        return;
    }
    
    for(UIView *view in detailsViews)
    {
        [view removeFromSuperview];
    }
    
    static int margin = 0;
    
    [detailsViews removeAllObjects];
    
    for (id item in objects)
    {
        if ([liked containsObject: item[REF_ID_NAME]] || [disliked containsObject:item[REF_ID_NAME]])
        {
            continue;
        }
        CGRect rect = CGRectMake(margin,  margin, self.view.frame.size.width - 2*margin, self.view.frame.size.width + 100 - margin*2 );
        SSDeckView *eventView =[[SSDeckView alloc]initWithFrame:rect];
        eventView.entityType = self.objectType;
        eventView.likeText = likeText;
        eventView.dislikeText = dislikeText;
        eventView.backgroundColor = deckViewContainer.backgroundColor;
        eventView.entity = item;
        eventView.delegate = self;
        eventView.cornerRadius = 0;
        [detailsViews addObject:eventView];
        [eventView refreshUI];
    }
    
    for (UIView *view in detailsViews)
    {
        view.hidden = YES;
        [deckViewContainer addSubview:view];
        
    }
}

- (void) headview
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = headerView.bounds;
    
    UIColor *from = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.3];
    UIColor *middle = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:.2];
    UIColor *to = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.05];
    UIColor *last = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.0];
    
    gradient.colors = [NSArray arrayWithObjects:(id)[from CGColor], (id)[middle CGColor], (id)[to CGColor], (id)[last CGColor], nil];
    [headerView.layer insertSublayer:gradient atIndex:0];
}

- (void) selectEntity : (int) index
{
    if(index < 0 || index >= [detailsViews count])
    {
        return;
    }
    SSDeckView *eventView =detailsViews[index];
    SSEntityEditorVC *entityEditor = [[SSApp instance] entityVCFor:eventView.entityType];
    entityEditor.item2Edit = eventView.entity;
    entityEditor.readonly = YES;
    entityEditor.itemType = eventView.entityType;
    entityEditor.view.tag = 1;
    [self showVC:entityEditor];
}

- (void) view:(SSDeckView *)view didSelect:(id)event
{
    SSEntityEditorVC *entityEditor = [[SSApp instance] entityVCFor:view.entityType];
    entityEditor.item2Edit = view.entity;
    entityEditor.readonly = YES;
    entityEditor.itemType = view.entityType;
    entityEditor.view.tag = 1;
    [self showVC:entityEditor];
}

- (void) showVC : (UIViewController *) vc
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @""
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSArray *) getItemViews
{
    return detailsViews;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (IBAction)toggleFilters
{
    [deckViewContainer toggleOpen];
}

- (void) setting
{
    UIView *window = navCtrl.view.window;
    ctrlView = navCtrl.view;
    if (![[window subviews] containsObject:self.menuViewControl.view])
    {
        [window addSubview:self.menuViewControl.view];
        [window bringSubviewToFront: self.navigationController.view];
        self.menuViewControl.delegate = self;
    }
    ctrlView.userInteractionEnabled = NO;
    //float ratio = 0.5f;
    self.menuViewControl.view.transform = makeTransform(1.4, 1.4, 0, 0, 0);
    [UIView animateWithDuration:0.5 animations:^{
        [self openMenu:ctrlView to: 1.0f];
        self.menuViewControl.view.transform = makeTransform(1, 1, 0, 0, 0);
    }];
}

- (void) menuVC:(SSMenuVC *) menuVC open : (float) ratio
{
    [self openMenu:ctrlView to:ratio];
}

- (void) openMenu:(UIView *) myView to:(float) percent;
{
    CALayer *layer = myView.layer;
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = percent*1.0 / -550;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -45.0f*percent * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
    rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, percent*230.0f, 0.0f, 0.0f);
    rotationAndPerspectiveTransform = CATransform3DScale(rotationAndPerspectiveTransform, 0.5f * (2-percent), 0.5f* (2-percent), 1.0f);
    layer.transform = rotationAndPerspectiveTransform;
}

- (void) closeMenu:(UIView *) myView;
{
    self.menuViewControl.view.transform = makeTransform(1, 1, 0, 0, 0);
    [UIView animateWithDuration:0.5
                     animations:^{
                         CALayer *layer = myView.layer;
                         layer.transform = CATransform3DIdentity;
                         self.menuViewControl.view.transform = makeTransform(1.4, 1.4, 0, 0, 0);
                     }
                     completion:^(BOOL finished) {
                         ctrlView.userInteractionEnabled = YES;
                         self.menuViewControl.view.transform = makeTransform(1, 1, 0, 0, 0);
                         
                     }
     
     ];
}

- (void) menuVC:(SSMenuVC *)menuVC didSelect:(id)entity
{
    UIViewController *viewCtrl = (UIViewController*) entity;
    viewCtrl.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menuIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    if ([viewCtrl isKindOfClass:SSTableViewVC.class])
    {
        SSTableViewVC *tableView = (SSTableViewVC*) viewCtrl;
        [tableView refreshOnSuccess:^(id data) {
            [navCtrl setViewControllers:@[viewCtrl] animated:NO];
            [self closeMenu:viewCtrl.navigationController.view];
            [tableView refreshUI];
        } onFailure:^(NSError *error) {
            
        }];
    }
    else
    {
        [navCtrl setViewControllers:@[viewCtrl] animated:NO];
        [self closeMenu:viewCtrl.navigationController.view];
    }
}


@end
