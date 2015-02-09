//
//  RoundView.h
//  iSwim2.0
//
//  Created by Anping Wang on 4/23/11.
//  Copyright 2011 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"

@interface SSRoundView : UIView

@property (nonatomic) float cornerRadius;

- (void) autofit;

@end
