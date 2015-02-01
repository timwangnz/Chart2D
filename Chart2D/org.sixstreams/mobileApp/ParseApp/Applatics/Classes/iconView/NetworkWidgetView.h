//
//  NetworkGraphWidgetVC.h
// AppliaticsMobile
//
//  Created by Anping Wang on 4/7/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import "SSWidgetView.h"
#import "IconsLayoutView.h"

@interface NetworkWidgetView : UIScrollView <IconViewDelegate>
{
    NSMutableArray *buttons;
    IBOutlet IconsLayoutView *iconView;
    NSArray *attributeValues;
    IBOutlet UIButton *uiBtnOrg;
    IBOutlet UIButton *uiBtnSocial;
    IBOutlet UIButton *uiBtnSales;
    IBOutlet UIButton *uiBtnTalent;
    IBOutlet UIScrollView *uiScrollView;
    IBOutlet UIView *uiCompetitors;
    IBOutlet UIImageView *legend;
    IBOutlet UIImageView *sgBkg;
    NSInteger mode;
}

@property BOOL rankedWithOrg;
@property BOOL rankedWithSocial;
@property BOOL rankedWithSales;
@property BOOL rankedWithTalent;

@property NSArray *data;
- (void) updateUI;

@end
