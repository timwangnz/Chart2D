//
// AppliaticsSplashView.h
// Appliatics
//
//  Created by Anping Wang on 9/27/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteHide)();

@interface SSSplashView : NSObject

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *background;
@property (nonatomic, strong) NSString *title;

@property int x;
@property int y;

- (void) showInView:(UIView *) view;
- (void) hide:(CompleteHide) complete;

@end
