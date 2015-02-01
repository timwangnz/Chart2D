//
// AppliaticsEntityVC.m
// Appliatics
//
//  Created by Anping Wang on 6/14/13.
//
#import "SSConnection.h"
#import "SSEntityVC.h"
#import "SSWidgetVC.h"
#import "SSWidgetWizardVC.h"

@interface SSEntityVC ()
{
    IBOutlet UIScrollView *container;
    NSMutableArray *widgetVCs;
    IBOutlet UIButton *back;
    SSWidgetVC *widget2Edit;
}

- (IBAction) addWidget;
- (IBAction) goBack;

@end

@implementation SSEntityVC


- (IBAction) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    [self view];
    return self;
}

- (void) updateWidget:(SSWidgetVC *)widget
{
    SSWidgetWizardVC *wizard = [[SSWidgetWizardVC alloc]init];
    wizard.viewId = [self.viewDef objectForKey:REF_ID_NAME];
    wizard.application = [self.viewDef objectForKey:@"application"];
    wizard.category = [self.viewDef objectForKey:@"category"];
    wizard.title = @"Edit Widget";
   
    widget2Edit = widget;
}

- (IBAction) addWidget
{
    [self updateWidget:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"Add"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(addWidget)];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.objectType = WIDGET;
    [super viewWillAppear:animated];
}

- (void) doLayout
{
    [self isIPad] ? [self doLayout4IPad ] : [self doLayout4IPhone];
}

- (void) doLayout4IPad
{
    CGFloat x = 10.0f;
    
    int hGap = 10;
    int vGap = 10;
    float accumulatedY = 10;
    int j = 0;
    int _columns = 3;
    
    container.frame = self.view.frame;
    SSWidgetVC *maxizedVC = nil;
    for(SSWidgetVC *item in widgetVCs)
    {
        if (item.maximized)
        {
            maxizedVC = item;
            break;
        }
    }
    
    if(maxizedVC)
    {
        for(SSWidgetVC *item in widgetVCs)
        {
            UIView *iconView =  item.view;
            if([item isEqual:maxizedVC])
            {
                iconView.hidden = NO;
                
                [container addSubview:iconView];
                CGRect child = container.frame;
                child.origin.x = hGap;
                child.origin.y = vGap;
                child.size.width = child.size.width - 2*hGap;
                child.size.height = child.size.height - 2*vGap;
                iconView.frame = child;
                [item updateUI];
            }
            else
            {
                iconView.hidden = YES;
            }
        }
    }
    else
    {
        for(SSWidgetVC *item in widgetVCs)
        {
            UIView *iconView =  item.view;
            iconView.hidden = NO;
            [container addSubview:iconView];
        }
        
        for(SSWidgetVC *item in widgetVCs)
        {
            UIView *iconView =  item.view;
            
            CGFloat iconWidth = [[item.widget objectForKey:@"width"] floatValue];
            //if (iconWidth == 0)
            {
                iconWidth = (container.frame.size.width - 2 * hGap) / _columns - hGap;
            }
            
            CGFloat iconHeight = [[item.widget objectForKey:@"height"] floatValue];
            if (iconHeight == 0)
            {
                iconHeight = 200;
            }
            
            iconView.frame = CGRectMake(x , accumulatedY, iconWidth, iconHeight);
            
            j ++;
            x = 10 + j * (iconWidth + hGap);
            
            if (j == _columns)
            {
                accumulatedY = accumulatedY + iconHeight + vGap;
                j = 0;
                x = 10;
            }
        }
        
        for(SSWidgetVC *item in widgetVCs)
        {
            [item updateUI];
        }
    }
    [container setContentSize: CGSizeMake(self.view.frame.size.width, accumulatedY)];
    
}
- (void) doLayout4IPhone
{
    
    CGFloat x = 10.0f;
    
    int vGap = 10;
    float accumulatedY = 10;
    SSWidgetVC *maxizedVC = nil;
    for(SSWidgetVC *item in widgetVCs)
    {
        if (item.maximized)
        {
            maxizedVC = item;
            break;
        }
    }
    
    if(maxizedVC)
    {
        for(SSWidgetVC *item in widgetVCs)
        {
            UIView *iconView =  item.view;
            if([item isEqual:maxizedVC])
            {
                iconView.hidden = NO;
                [container addSubview:iconView];
                CGRect child = container.frame;
                child.origin.x = 4;
                child.origin.y = 4;
                child.size.width = child.size.width - 2*4;
                child.size.height = child.size.height - 2*4;
                
                iconView.frame = child;
                [item updateUI];
            }
            else
            {
                iconView.hidden = YES;
            }
        }
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        for(SSWidgetVC *item in widgetVCs)
        {
            UIView *iconView =  item.view;
            iconView.hidden = NO;
            CGFloat iconWidth = self.view.frame.size.width - 20;
            
            CGFloat iconHeight = [[item.widget objectForKey:@"height"] floatValue];
            if (iconHeight == 0)
            {
                iconHeight = 200;
            }
            
            iconView.frame = CGRectMake(x , accumulatedY, iconWidth, iconHeight);
            
            [container addSubview:iconView];
            [item updateUI];
            
            accumulatedY = accumulatedY + iconHeight + vGap;
        }
    }
    [container setContentSize: CGSizeMake(self.view.frame.size.width, accumulatedY)];
}


- (void) refreshUI
{
    for(SSWidgetVC *item in widgetVCs)
    {
        [item.view removeFromSuperview];
    }
    
    widgetVCs = [NSMutableArray array];
    
    NSArray *sorted = [self.objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int seq1 = [[obj1 objectForKey:SEQUENCE] intValue];
        int seq2 = [[obj2 objectForKey:SEQUENCE] intValue];
        return seq1 > seq2;
    }];
    
    for (id widget in sorted)
    {
        SSWidgetVC *widgetVC = [[SSWidgetVC alloc]init];
        [self addChildViewController:widgetVC];
        widgetVC.entity = self.entity;
        widgetVC.containerVC = self;
        widgetVC.widget = widget;
        [widgetVCs addObject:widgetVC];
        [widgetVC didMoveToParentViewController:self];
    }
    
    [self doLayout];
}

@end
