//
// AppliaticsIconView.h
// AppliaticsMobile
//
//  Created by Anping Wang on 3/31/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconViewVC.h"

@interface IconsLayoutView : UIView <IconViewDelegate>


@property int width;
@property int height;
@property int topMargin;
@property int vGap;
@property int columns;


@property (strong) id<IconViewDelegate> iconViewDelegate;

- (void) setItems:(NSArray *) items;
- (IBAction)reorder:(id)sender;
- (void)doLayout;



//to be overridden by subclass of layout view
- (IconViewVC *) createIconView :(id) userInfo;
- (NSArray *) getIconViews;

@end
