//
// AppliaticsWidgitVCViewController.h
// Appliatics
//
//  Created by Anping Wang on 6/14/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//


@class SSEntityVC;

@interface SSWidgetVC : UIViewController

@property (nonatomic, strong) IBOutlet SSEntityVC *containerVC;
@property (nonatomic, strong) id widget;
@property (nonatomic, strong) id entity;
@property  BOOL maximized;

- (void) updateUI;
- (void) refreshUI;
- (IBAction) doMaxmin:(id)sender;

@end
