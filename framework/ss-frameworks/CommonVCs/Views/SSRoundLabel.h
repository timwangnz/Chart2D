//
//  RoundLabel.h
// Appliatics
//
//  Created by Anping Wang on 9/16/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"

@interface SSRoundLabel : UILabel

@property BOOL showShadow;
@property (nonatomic) float cornerRadius;
@property (assign) CGFloat multiLineSpacing;

-(CGFloat)resizeToFit;

@end
