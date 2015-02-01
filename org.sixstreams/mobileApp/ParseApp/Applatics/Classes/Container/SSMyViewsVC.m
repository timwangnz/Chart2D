//
// AppliaticsContentVC.m
// Appliatics
//
//  Created by Anping Wang on 6/10/13.
//

#import "SSMyViewsVC.h"
#import "SSConnection.h"
#import "SSDataViewVC.h"
#import "SSViewDefWidardVC.h"
#import "SSJobApplicationVC.h"
#import "SSIconView.h"

@interface SSMyViewsVC ()<SSListOfValueDelegate, SSTableViewVCDelegate>
{
    NSMutableArray *appViews;
    IBOutlet UITableView *menuTable;
    NSMutableArray *iconViews;
    IBOutlet UIScrollView *iconsView;
    UIView *childView;
    SSDataViewVC *childVC;
    IBOutlet UILabel *msgLabel;
    IBOutlet UIButton *btnCreateApp;
}

- (IBAction)addViewDef : (id)sender;

@end

@implementation SSMyViewsVC

- (void) selectView:(id)viewVC
{
    if (![self isIPad])
    {
        [self.navigationController pushViewController:viewVC animated:YES];
    }
    else
    {
        [self doNavLayout:viewVC];
    }
}

- (void) updateUI
{
    if ([appViews count]==0)
    {
        msgLabel.hidden = NO;
        msgLabel.text = [NSString stringWithFormat:@"%@ - %@",
                         [self.entity objectForKey:NAME],
                         @"No views found"];
    }
    else{
        msgLabel.hidden = YES;
        [self setItems];
    }
    [self doLayout];
}
//
//when an item is selected from menu
//
- (void) entityChanged
{
    for (SSDataViewVC *dataViewVC in iconViews)
    {
        [dataViewVC.iconView removeFromSuperview];
    };
    btnCreateApp.hidden = !self.entity;
    iconViews = [NSMutableArray array];
    [childView removeFromSuperview];
    childView = nil;
    childVC = nil;
    self.title = [self.entity objectForKey:NAME];
    [self refresh];
}

- (void) refresh
{
    if (self.entity == nil)
    {
        return;
    }
    
    SSConnection *syncher = [SSConnection connector];
    [syncher objects:[NSPredicate predicateWithFormat:@"packageId=%@", [self.entity objectForKey:REF_ID_NAME]]
              ofType:APP_VIEW_SUBSCRIPTION
             orderBy:nil
           ascending:NO
              offset:0
               limit:200
           onSuccess:^(NSDictionary *data) {
               appViews = [data objectForKey:PAYLOAD];
               NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:SEQUENCE  ascending:YES];
               [appViews sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
               appViews = [appViews copy];
               [self updateUI];
           }
           onFailure:^(NSError *error) {
               DebugLog(@"Error occured %@", error);
           }
     ];
}

- (void) doLayout
{
    if (childVC != nil)
    {
        [self doNavLayout:childVC];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES];
        [self doExpandLayout];
    }
    
    if (self.entity != nil)
    {
        UIBarButtonItem *addAcc = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Add View"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(addViewDef:)];
        NSArray *arrBtns = [[NSArray alloc]initWithObjects:addAcc, nil];
        self.navigationItem.rightBarButtonItems = arrBtns;
    }
    else
    {
        self.navigationItem.rightBarButtonItems = nil;
    }
}

- (void) doExpandLayout
{
    self.columns = [self isIPad] ? 8 : 4;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    float _vGap = 10, _topMargin = 20;
    int i = 0;
    
    iconsView.frame = self.view.frame;
    
    float height;
    for(SSDataViewVC *item in iconViews)
    {
        UIView *iconView =  item.iconView;
        int row = i / self.columns;
        int col = i - row * self.columns;
        
        CGFloat iconWidth = iconView.frame.size.width;
        CGFloat iconHeight = iconView.frame.size.height;
        
        int hGap = (self.view.frame.size.width - iconWidth * self.columns)/(self.columns + 1);
        
        iconView.frame = CGRectMake(x + col * (iconWidth + hGap) + hGap, y + row * (iconHeight + _vGap) + _vGap + _topMargin, iconWidth, iconHeight);
        
        [iconsView addSubview:iconView];
        [item updateUI];
        if (col == 0)
        {
            height = height + iconView.frame.size.height;
        }
        i++;
    }
    [iconsView setContentSize: CGSizeMake(self.view.frame.size.width, height + 100)];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) doNavLayout:(SSDataViewVC *)viewVC;
{
    static int iconWidth = 64;
    static int iconHeight = 84;
    float sideWidth = 1.5 * iconWidth;
    
    if (childVC)
    {
        childVC.selected = NO;
    }
    
    if (childView)
    {
        [childView removeFromSuperview];
    }
    
    CGRect rect = self.view.frame;
    
    rect.origin.x = sideWidth;
    rect.size.width = rect.size.width - sideWidth;
    
    viewVC.view.frame = rect;
    childVC = viewVC;
    childVC.selected = YES;
    childView = viewVC.view;
    self.columns = 1;
    
    CGFloat x = (sideWidth - iconWidth) / 2;
    CGFloat y = 0.0f;
    float _vGap = 10, _topMargin = 10;
    int i = 0;
    
    rect = iconsView.frame;
    rect.size.width = sideWidth;
    iconsView.frame = rect;
    
    for(SSDataViewVC *item in iconViews)
    {
        UIView *iconView =  item.iconView;
        [iconsView addSubview:iconView];
    }
    
    float height;
    for(SSDataViewVC *item in iconViews)
    {
        UIView *iconView =  item.iconView;
        int row = i / self.columns;
        int col = i - row * self.columns;
        
        CGFloat w = iconWidth;//iconView.frame.size.width;
        CGFloat h = iconHeight;//iconView.frame.size.height;
        
        iconView.frame = CGRectMake(x , y + row * (h + _vGap) + _vGap + _topMargin, w, h);
        
        [item updateUI];
        if (col == 0)
        {
            height = height + iconView.frame.size.height;
        }
        i++;
    }
    [iconsView setContentSize: CGSizeMake(sideWidth, height + 100)];
    [self.view addSubview:viewVC.view];
}

- (SSDataViewVC *) createIconView :(id) subscriptioin
{
    SSDataViewVC *listVC = [[SSDataViewVC alloc] init];
    listVC.subscription  = subscriptioin;
    listVC.parentVC = self;
    return listVC;
}

- (NSArray *) getIconViews
{
    return iconViews;
}

- (void) clearIconViews
{
    for (SSDataViewVC *dataviewVC in iconViews)
    {
        [dataviewVC.iconView removeFromSuperview];
    }
    iconViews = nil;
}

- (void) setItems
{
    [self clearIconViews];
    if (appViews)
    {
        iconViews = [[NSMutableArray alloc] initWithCapacity:[appViews count]];
        for (id item in appViews)
        {
            SSDataViewVC *listView = [self createIconView: item];
            [iconViews addObject:listView];
        }
    }
    [self doLayout];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    iconsView.frame = self.view.frame;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    btnCreateApp.hidden = !self.entity;
    [self doLayout];
}

- (void)orientationChanged:(NSNotification *)notification {
    
    [self doLayout];
}

- (void) listOfValues:(id) tableView didSelect : (id) entity
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:[entity objectForKey:REF_ID_NAME] forKey:APP_VIEW_ID];
    [dic setObject:[entity objectForKey:NAME] forKey:NAME];
    
    [dic setObject:[self.entity objectForKey:REF_ID_NAME] forKey:PACKAGE_ID];
    
    [[SSConnection connector] createObject:dic ofType:APP_VIEW_SUBSCRIPTION
                                 onSuccess:^(id data) {
                                     [self dismissViewControllerAnimated:YES completion:^{
                                         [self refresh];
                                     }
                                      ];
                                 } onFailure:^(NSError *error) {
                                     [self showAlert:@"Failed to subscribe the app" withTitle:@"Error"];
                                 }];
}

- (void) tableViewVC:(id) tableViewVC didLoad : (id) objects
{
    NSMutableArray *subscribed = [NSMutableArray array];
    for (id item in objects)
    {
        NSString *appId = [item objectForKey:REF_ID_NAME];
        for (id sub in appViews) {
            NSString *subAppId = [sub objectForKey:APP_VIEW_ID];
            if ([appId isEqualToString:subAppId])
            {
                [subscribed addObject:item];
            }
        }
    }
    [objects removeObjectsInArray:subscribed];
    //we want to remove apps that we already subscrib
}

- (IBAction) addViewDef :(id) sender
{
    SSJobApplicationVC *viewDefList = [[SSJobApplicationVC alloc]init];
    viewDefList.listOfValueDelegate = self;
    viewDefList.tableViewDelegate = self;
    viewDefList.editable = NO;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController: viewDefList];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.parentViewController presentViewController:nav animated:YES completion:^{
        //
    }];
}

-(void) viewDidDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

@end
