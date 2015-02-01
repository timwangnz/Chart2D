//
//  GLViewVC.m
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/1/12.
//  Copyright (c) 2012 Oracle. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>
#import "SSDrawableVC.h"
#import "SSDrawableLayer.h"
#import "SSGraph.h"
#import "SSAnimiate.h"


@interface SSDrawableVC ()
{
    BOOL hideMaster;
    NSTimer *timerForStopWebService;
   
    BOOL isupdating;
    IBOutlet UIView *viewControlPanel;
    
    __weak IBOutlet UIButton *btnDeletePage;
    __weak IBOutlet UIButton *btnAddPage;
    __weak IBOutlet UIButton *btnPage;
    IBOutlet UIView *vToolbox;
    __weak IBOutlet UIButton *btnDeleteSel;
    __weak IBOutlet UIButton *btnSettings;
    IBOutlet UIView *vColors;
    IBOutlet UIView *vTools;
    IBOutlet UIView *vSettings;
    //__weak IBOutlet SSGLKVC *glkVC;
    //SSDrawableLayer *drawableLayer;
    NSInteger page;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UIButton *btnRedo;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (retain, nonatomic) IBOutlet SSDrawableLayer *glView;
@property (weak, nonatomic) IBOutlet UILabel *guessed;



- (IBAction) grid:(id)sender;
- (IBAction) color:(UIButton *)sender;
- (IBAction) selectTool:(UIButton *)sender;
- (IBAction) toggleOptions:(UIButton *)sender;
- (IBAction) nextPage:(UIButton *)sender;
- (IBAction) previousPage:(UIButton *)sender;
- (IBAction) animation:(id)sender;

@end

@implementation SSDrawableVC

- (IBAction)animation:(id)sender
{
    if(!self.glView.isAnimating)
    {
        [self.glView startAnimation];
    }
    else
    {
        [self.glView stopAnimation];
    }
    
}

- (IBAction)addPage:(id)sender {
    [self.book createPageOnSucess:^(id data, NSError *error) {
        if(error)
        {
            [self showAlert:@"Failed to creat a new page, please try later" withTitle:@"Error"];
            return;
        }
        page = [self.book pages] - 1;
        [self changeGraph:data];
        [self updateUI];
    }];
}

- (IBAction)deletePage:(id)sender
{
    if([self.book pages] < 2)
    {
        return;
    }
    [self.book deletePage:self.graph OnSuccess:^(id data, NSError *error) {
        if(error)
        {
            [self showAlert:@"Failed to delete the page, please try later" withTitle:@"Error"];
            return;
        }        page = 0;
        [self changeGraph: [self.book getFirstPage]];
        [self updateUI];
    }];
}

- (IBAction)deleteSelection:(id)sender {
    [self.graph deleteSelection];
    [self updateUI];
}

- (IBAction) toggleOptions:(UIButton *)sender
{
    UIView *parent = sender.superview;
    CGRect rect = parent.frame;
    
    int iconSize = 38;
    int edge = 1;
    int gap = 2;
    
    NSInteger numberOfChildren = [parent.subviews count];
    
    if (rect.size.height < (numberOfChildren) * iconSize)
    {
        rect.size.height = (numberOfChildren) * (iconSize + gap);
    }
    else
    {
        rect.size.height = iconSize + 2*edge;
    }

    if (rect.size.height > iconSize + 2*edge)
    {
        parent.frame = rect;
        CGRect rect = sender.frame;
        rect.origin.y = parent.frame.size.height - iconSize;
    
        for(UIView *child in parent.subviews)
        {
            CGRect rect = sender.frame;
            child.frame = rect;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            for(UIView *child in parent.subviews)
            {
                CGRect rect = child.frame;
                child.hidden = NO;
                rect.origin.y = edge + (gap + iconSize)*(child.tag);
                child.frame = rect;
            }
        }];
    }
    else
    {
        [parent bringSubviewToFront:sender];
        [UIView animateWithDuration:0.5 animations:^{
            
            for(UIView *child in parent.subviews)
            {
                CGRect rect = sender.frame;
                child.frame = rect;
            }
            
        } completion:^(BOOL finished) {
            for(UIView *child in parent.subviews)
            {
                if ([child isEqual:sender]) {
                    continue;
                }
                child.hidden = YES;
               
            }
            [UIView animateWithDuration:0.2 animations:^{
                parent.frame = rect;
                CGRect rect = sender.frame;
                rect.origin.y = edge;
                
                sender.frame = rect;
            }];
        }];
    }
    [parent setNeedsDisplay];
}

-(IBAction) color:(UIButton *)sender
{
    self.glView.selectedColor = sender.backgroundColor;
    [self toggleOptions:sender];
}


-(IBAction) grid:(id)sender
{
    self.glView.showGrid = !self.glView.showGrid;
    [self.glView setNeedsLayout];
}

- (IBAction)nextPage:(id)sender
{
    if (page < [self.book pages] - 1)
    {
        page ++;
        SSGraph *graph = [self.book getPageAtIndex:page];
        if (graph != nil)
        {
            [graph getDetailsOnSuccess:^(id data, NSError *error) {
                if (error)
                {
                    [self showAlert:@"Failed to get page details, please try again later" withTitle:@"Error"];
                    return;
                }
                [self changeGraph:graph];
            }];
        }
        [self updateUI];
    }
}

- (IBAction)previousPage:(id)sender
{
    page --;
    if (page < 0)
    {
        page = 0;
        return;
    }
    
    SSGraph *graph = [self.book getPageAtIndex:page];
    if (graph != nil)
    {
        [graph getDetailsOnSuccess:^(id data, NSError *error) {
            if (error)
            {
                [self showAlert:@"Failed to get page details, please try again later" withTitle:@"Error"];
                return;
            }
            [self changeGraph:graph];
        }];
    }
    [self updateUI];

}

- (IBAction)clear:(id)sender
{
    [self.glView clearDrawing];
    [self updateUI];
}

- (IBAction)undo:(id)sender {
    [self.graph undo];
    [self.glView setNeedsLayout];
    [self updateUI];
}

- (IBAction)redo:(id)sender
{
    [self.graph redo];
    [self.glView setNeedsLayout];
    [self updateUI];
}

- (IBAction)selectTool:(UIButton *)sender
{
    self.glView.tool = (PaintTool) sender.tag;
    [self toggleOptions:sender];
    [self.graph clearSelection];
    [self.glView setNeedsLayout];
    [self updateUI];
}

- (void) sync
{
    
}

//start watching this
- (IBAction) watch:(UIBarButtonItem*)sender
{
    [timerForStopWebService invalidate];
    if (self.graph.readonly)
    {
        if ([sender.title isEqualToString:@"Watch"]) {
            timerForStopWebService = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(sync) userInfo:nil repeats:YES];
            sender.title =@"Stop";
        }
        else{
            sender.title = @"Watch";
        }
    }
}

- (void) graphWillChange
{
    self.glView.hidden = YES;
    self.glView.graph = nil;
    page = 0;
}

- (void) changeGraph:(SSGraph *) graphObject
{
    if(!graphObject)
    {
        return;
    }
    self.graph = graphObject;
    self.glView.graph = self.graph;
    self.glView.hidden = NO;
    self.title = self.graph.name;
    [self.glView setNeedsLayout];
    vToolbox.hidden = NO;
    [self updateUI];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timerForStopWebService invalidate];
    [self.graph save];
    //[self.glView tearDownGL];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title= @"Black Board";
    self.glView.gridColor = [UIColor grayColor];
    self.glView.gridHeight = 50;
    self.glView.gridWidth = 50;
    self.glView.selectedWidth = 2;
    [self.glView setBrushColorWithRed: 1.0 green:1.0 blue:1.0];
    self.glView.showGrid = YES;
    self.glView.gridWidth = 50;
    self.glView.gridHeight = 50;
    self.glView.gridColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.glView draw];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.glView.drawableDelegate = self;
    self.glView.name = @"Graphic View";

    [self updateUI];
    self.glView.selectedColor= [UIColor redColor];
    if(self.graph)
    {
        [self changeGraph:self.graph];
    }
    
   
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (IBAction)hideUnhide:(UIButton *)sender
{
    hideMaster = !hideMaster;
    [sender setTitle:hideMaster ? @"::>" :  @"<::" forState:UIControlStateNormal];
    if ([self isIPad])
    {
        self.svc.delegate = nil;
        self.svc.delegate = self;
        [self.svc.view setNeedsLayout];
        [self.svc willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)splitViewController: (UISplitViewController*)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return hideMaster;
}

- (void) viewDidRefresh:(SSDrawableLayer *) glView
{
    [self updateUI];
}

- (IBAction)replay:(id)sender
{
    [self.graph replay];
}

- (IBAction)save:(id)sender
{
    [self.glView.graph saveOnSuccess:^(id data) {
        if (self.delegate)
        {
            [self.delegate graphView:self didPerform:@"save"];
        }
    } onFailure:^(NSError *error) {
        [self showAlert:@"Failed to save, try again in a few moments please" withTitle:@"Network Erorr"];
    }];
    [self toggleOptions:sender];
}

- (void) updateUI
{
    vTools.hidden = vColors.hidden = vSettings.hidden = self.graph.readonly || self.graph == nil;
    self.btnRedo.enabled = [self.glView isRedoable];
    self.btnUndo.enabled = [self.glView isUndoable];
    btnDeleteSel.hidden = ![self.graph hasSelection];
    btnPage.hidden = self.book == nil;
    vToolbox.hidden = self.book == nil;
    [btnPage setTitle:[NSString stringWithFormat:@"%d/%d", (int) page + 1, (int)[self.book pages]] forState:UIControlStateNormal];
   
}

- (IBAction)exportToAlbum:(id)sender
{
    [self.glView captureToPhotoAlbum];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
