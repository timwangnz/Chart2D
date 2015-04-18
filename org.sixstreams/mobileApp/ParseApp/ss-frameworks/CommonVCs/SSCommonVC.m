//
//  SSCommonVC.m
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSCommonVC.h"
#import "SSValueField.h"
#import "SSDatePickerVC.h"
#import "SSLovTextField.h"
#import "SSDateTextField.h"
#import "SSAddressField.h"
#import "SSAddressVC.h"
#import "SSAppDelegate.h"
#import "SSTransitionDelegate.h"

@interface SSCommonVC ()<SSValueFieldDelegate>
{
    SSTransitionDelegate *transitionDelegate;
    OnAlertSelect myAlertBlock;
}

@end

@implementation SSCommonVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    transitionDelegate = [[SSTransitionDelegate alloc]init];
    self.transitioningDelegate = transitionDelegate;
    [self.navigationController.navigationBar setTitleTextAttributes:
        [NSDictionary dictionaryWithObject:[UIColor colorWithRed:44.0/255 green:171.0/255 blue:226.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName]];
    
    self.navigationController.navigationBar.translucent = NO;

}

- (UITapGestureRecognizer *) addTapEvent :(UIView *) view onTap:(SEL) onTap
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:onTap];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [view addGestureRecognizer:singleTap];
    [view setUserInteractionEnabled:YES];
    return singleTap;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void) popView:(UIView *) uiView
{
    if(self.isIPad)
    {
        UIViewController *uiVC = [[UIViewController alloc]init];
        uiVC.view = uiView;
        [self showPopup:uiVC sender:self];
    }
    else{
        SSAppDelegate *delegate = (SSAppDelegate*)[UIApplication sharedApplication].delegate;
        UIView *rootView = delegate.window;
        
        [rootView addSubview:uiView];
        [rootView bringSubviewToFront:uiView];
        
        uiView.frame = delegate.window.frame;
        uiView.alpha = 0.0;
        
        [UIView animateWithDuration:1 animations:^{
            uiView.alpha = 0.99;
        } completion:^(BOOL finished) {
           uiView.alpha = 1;
        }];
    }
}

- (void) dissmissView:(UIView *) uiView
{
    if(self.isIPad)
    {
       //
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            uiView.alpha = 0;
        } completion:^(BOOL finished) {
            [uiView removeFromSuperview];
            uiView.alpha = 0.99;
        }];
    }
}

- (void) showAlert:(NSString *)alert
         withTitle:(NSString *)title
       cancelTitle:(NSString *)cancelTitle
           okTitle:(NSString *)okTitle
          onSelect:(OnAlertSelect) onAlertSelect;
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                    message:alert
                                                   delegate:self
                                          cancelButtonTitle:cancelTitle
                                          otherButtonTitles:okTitle, nil];
    
    myAlertBlock = onAlertSelect;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (myAlertBlock)
    {
        myAlertBlock ([alertView buttonTitleAtIndex:buttonIndex]);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    myAlertBlock = nil;
}
- (void) showAlert:(NSString *)alert withTitle:(NSString *)title
{
    [[[UIAlertView alloc]initWithTitle:title
                               message:alert
                              delegate:self
                     cancelButtonTitle:ALERT_OK_TITLE
                     otherButtonTitles:nil] show];
}

- (BOOL) isIPad
{
 
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    
}

- (void) showPopup:(id)popupVC sender:(id) sender
{
    [self showPopup:popupVC sender:sender permittedArrowDirections:UIPopoverArrowDirectionAny];
}

- (void) hideKeyboard:(UIView *) uiView
{
    [uiView resignFirstResponder];
    for (UIView *childView in uiView.subviews) {
        [self hideKeyboard:childView];
    }
}

- (id) addBarItem: (id) item to:(id) parent
{
    
    if (item == nil)
    {
        NSMutableArray *btns = [NSMutableArray array];
        [btns addObject:parent];
        return btns;
    }
    
    if (parent == nil)
    {
        if ([item isKindOfClass:NSArray.class])
        {
            return item;
        }
        
        NSMutableArray *btns = [NSMutableArray array];
        [btns addObject:item];
        return btns;
    }
    
    if ([parent isKindOfClass: NSMutableArray.class]) {
        if ([item isKindOfClass:NSArray.class])
        {
            [parent addObjectsFromArray:item];
        }
        else
        {
            [parent addObject:item];
        }
        return parent;
    }
    else
    {
        NSMutableArray *btns = [NSMutableArray array];
        [btns addObject:parent];
        if ([item isKindOfClass:NSArray.class])
        {
            [btns addObjectsFromArray:item];
        }
        else
        {
            [btns addObject:item];
        }
        return btns;
    }
}

- (void) clearForm:(UIView *) uiView
{
    if ([uiView isKindOfClass:[UITextView class]])
    {
        UITextView *tv = (UITextView *) uiView;
        tv.text = nil;
        return;
    }
    if ([uiView isKindOfClass:[UITextField class]])
    {
        UITextField *tf = (UITextField *) uiView;
        tf.text = nil;
        return;
    }
    for (UIView *childView in uiView.subviews) {
        [self clearForm:childView];
    }
}

- (void) valueField:(SSValueField *)valueField valueChanged:(id)item
{
    //dont do anything
    DebugLog(@"%@", valueField.text);
    //
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isKindOfClass:[SSValueField class]])
    {
        SSValueField *valueEditor = (SSValueField *) textField;
        
        valueEditor.valueDelegate = self;
        
        UIViewController *candidateVC = [valueEditor getCandidateVC];
        if (candidateVC != nil)
        {
            [self showPopup:candidateVC sender:textField];
            return NO;
        }
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
   
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)value
{
    return YES;
}

- (void) hideKeyboard
{
    [self hideKeyboard:self.view];
}

- (void) popupVC:(UIViewController *) popupVC
{
    if (self.navigationController)
    {
        [self.navigationController pushViewController:popupVC animated:YES];
    }
    else
    {
        popupVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:popupVC animated:YES completion:nil];
    }
}

- (void) popDownVC:(UIViewController *)popDownVC
{
    if (popDownVC.navigationController)
    {
        [popDownVC.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [popDownVC dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void) showPopup:(UIViewController*)popupVC sender:(id) sender permittedArrowDirections:(UIPopoverArrowDirection) direction
{
    if(false && self.navigationController && ![popupVC isKindOfClass:[UIImagePickerController class]])
    {
        [self.navigationController pushViewController:popupVC animated:YES];
    }
    else{
        if([self isIPad])
        {
            self.genericPickerPopover = [[UIPopoverController alloc] initWithContentViewController:popupVC];
            UIView *senderView = (UIView *) sender;
            if([popupVC isKindOfClass:[SSCommonVC class]])
            {
                ((SSCommonVC *)popupVC).genericPickerPopover = self.genericPickerPopover;
            }
            if ([sender isKindOfClass:[UIButton class]])
            {
                [self.genericPickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            else
            {
                [self.genericPickerPopover presentPopoverFromRect:senderView.bounds inView: senderView permittedArrowDirections:direction animated:YES];
            }
        }
        else
        {
            if([popupVC isKindOfClass:[UIImagePickerController class]])
            {
                [self presentViewController:popupVC animated:YES completion:nil];
            }
            else
            {
                [self popupVC:popupVC];
            }
        }
    }
}

@end


@implementation UITextField(SSCommonVC)

- (BOOL) isEmpty
{
    return !self.text || [self.text length]==0;
}
@end
