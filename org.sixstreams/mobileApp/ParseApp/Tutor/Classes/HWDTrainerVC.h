//
//  HWDTrainerVC.h
//  HandWritingDemo
//
//  Created by Anping Wang on 12/22/12.
//  Copyright (c) 2012 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSDrawableView.h"

@interface HWDTrainerVC : UIViewController<GLViewDelegate>


@property (weak, nonatomic) SSGraph *graph;
@property (weak, nonatomic) IBOutlet UILabel *similarity;
@property (weak, nonatomic) IBOutlet UILabel *suggest;
@property (weak, nonatomic) IBOutlet UITextField *stokes;

- (IBAction)clearTrainingSet:(id)sender;
- (IBAction)clearCanvas:(id)sender;
- (IBAction)exportTrainingData;
@end
