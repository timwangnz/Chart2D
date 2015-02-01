//
// AppliaticsStyleEditor.m
// Appliatics
//
//  Created by Anping Wang on 9/28/13.
//

#import "SSColumnEditor.h"

#import "SSTableViewVC.h"
#import "SSColorField.h"
#import "SSLovTextField.h"

@interface SSColumnEditor ()<SSTableViewVCDelegate>
{
    __weak IBOutlet UITableView *columnListView;
    __weak IBOutlet UIView *editorView;
    IBOutlet SSColorField *tfBackground;
    IBOutlet UISegmentedControl *sVisible;
    IBOutlet UITextField *tfName;
    IBOutlet UITextField *tfBinding;
    IBOutlet SSLovTextField *tfMetaType;
    IBOutlet SSLovTextField *tfUIType;
    
    IBOutlet SSLovTextField *tfDataType;
    IBOutlet UITextView *tvMetaData;
    IBOutlet UITextField *tfWidth;
    IBOutlet SSColorField *tfColor;
    
    IBOutlet UIButton *bExpression;
    IBOutlet SSTableViewVC *tvColumnsVC;
 
    IBOutlet UIButton *bVisible;
    
    IBOutlet UIButton *bReadonly;
    IBOutlet UIButton *bTotal;
    IBOutlet UISlider *sWidth;
    IBOutlet UISegmentedControl *scAlignment;
    id itemSelected;
    int selectedRow;
}

- (IBAction) addNewColumn:(id)sender;

@end

@implementation SSColumnEditor

- (IBAction)onSliderChange:(UISlider *)sender
{
    tfWidth.text = [NSString stringWithFormat:@"%.0f", sender.value];
}

- (IBAction) addNewColumn:(id)sender
{
    NSMutableDictionary *entity = [NSMutableDictionary dictionary];
    [entity setValue:@"new Col" forKey:NAME];
    [entity setValue:@"1" forKey:VISIBLE];
    [entity setValue:@"100" forKey:@"width"];
    [entity setValue:@"composite" forKey:@"columnType"];
    [entity setValue:[NSNumber numberWithInteger:[tvColumnsVC.objects count]] forKey:SEQUENCE];
    [tvColumnsVC.objects addObject:entity];
    [tvColumnsVC refreshUI];
}

//no need to confirm as it is not saved till parent is saved
- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) save
{
    [self entityWillSave:self.item2Edit];
    [tvColumnsVC refreshUI];
    if (self.entityEditorDelegate && [self.entityEditorDelegate respondsToSelector:@selector(entityEditor:didSave:)]) {
        [self.entityEditorDelegate entityEditor:self didSave:self.item2Edit];
    }
}

- (void) initItem
{
    
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                  target:self
                                                  action:@selector(save)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                              target:self
                                                                                              action:@selector(back)];
    
}


- (void) uiWillUpdate:(id) entity
{
    //[super uiWillUpdate:entity];
    self.readonly = NO;
    [self linkEditFields];
}


- (NSString *) tableViewVC:(id)tableViewVC cellText:(id)rowItem atCol:(int)col
{
    return [rowItem objectForKey:NAME];
}

- (void) tableViewVC:(id)tableViewVC showEditor:(SSEntityEditorVC *)editor
{
    if(!self.isIPad)
    {
        if(editorView.frame.origin.x > self.view.frame.size.width/2)
        {
            editorView.frame = CGRectMake(self.view.frame.size.width, editorView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            self.item2Edit = itemSelected;
            [self uiWillUpdate:itemSelected];
            [UIView animateWithDuration:0.5 animations:^{
                editorView.frame = CGRectMake(0, editorView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            }];
        } else if(editorView.frame.origin.x > 0 && [itemSelected isEqual:self.item2Edit])
        {
            //[self uiWillUpdate:itemSelected];
            [UIView animateWithDuration:0.5 animations:^{
                editorView.frame = CGRectMake(0, editorView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            }];
        } else{
            self.item2Edit = itemSelected;
            [self uiWillUpdate:itemSelected];
        }
    }
    else
    {
        self.item2Edit = itemSelected;
        [self uiWillUpdate:itemSelected];
    }
}

- (SSEntityEditorVC *) tableViewVC:(id) tableViewVC createEditor : (id) entity
{
    itemSelected = entity;
    return self;
}

- (BOOL) tableViewVC:(id) tableViewVC shouldDelete : (id) entity
{
    [tvColumnsVC.objects removeObject:entity];
    [tvColumnsVC refreshUI];
    return NO;
}

//used for iphone
-(void)handleGesture: (UIPanGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
       if (editorView.frame.origin.x > self.view.frame.size.width/2)
       {
           [UIView animateWithDuration:0.5 animations:^{
               editorView.frame = CGRectMake(self.view.frame.size.width, editorView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
               
           }];
       }
    }
    else
    {
        CGPoint translation = [gestureRecognizer translationInView: self.view];
        
        if (translation.x <= 0) {
            return;
        }
        
        float mX = editorView.center.x;
        float mY = editorView.center.y;
        
        editorView.center = CGPointMake(mX + translation.x, mY);
        
        [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    tvColumnsVC.objects = [self.viewDef objectForKey:COLUMN_DEFS];
    tvColumnsVC.tableViewDelegate = self;
    tvColumnsVC.titleKey = NAME;
    tvColumnsVC.editable = YES;
    [tvColumnsVC refreshUI];
    self.readonly = NO;
    self.title = @"Edit View Columns";
    if(!self.isIPad)
    {
        
        editorView.frame = self.view.bounds;
        columnListView.frame = self.view.bounds;
        
        editorView.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0);
        UIPanGestureRecognizer *panGestureRec = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
        [editorView addGestureRecognizer:panGestureRec];
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    
}

@end
