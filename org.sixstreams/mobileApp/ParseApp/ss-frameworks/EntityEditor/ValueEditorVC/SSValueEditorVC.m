//
//  SSValueEditorVCViewController.m
//  Medistory
//
//  Created by Anping Wang on 10/20/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import "SSValueEditorVC.h"

@interface SSValueEditorVC ()
{
    NSString *title;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@end

@implementation SSValueEditorVC

- (id) initWithValueField:(SSValueField *)valueField
{
    self = [super init];
    if(self)
    {
        title = valueField.placeholder;
        self.field = valueField;
    }
    return self;
}

- (IBAction)cancel:(id)sender
{
    [self popDownVC:self];
}

- (IBAction)save:(id)sender
{
    [self popDownVC:self];
}

- (void) popDownVC:(UIViewController *) popupVC
{
    if (self.parentVC.navigationController && !self.parentVC.navigationController.navigationBarHidden)
    {
        [self.parentVC.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) popupVC:(UIViewController *) popupVC
{
    if (self.parentVC.navigationController && !self.parentVC.navigationController.navigationBarHidden)
    {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @""
                                       style: UIBarButtonItemStylePlain
                                       target: nil action: nil];
        
        [self.parentVC.navigationItem setBackBarButtonItem: backButton];
        [self.parentVC.navigationController pushViewController:popupVC animated:YES];
    }
    else
    {
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController: popupVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.parentVC presentViewController:nav animated:YES completion:nil];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = title;
}

@end
