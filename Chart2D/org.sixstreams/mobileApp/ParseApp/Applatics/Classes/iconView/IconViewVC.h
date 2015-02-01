//
//  IconViewVC.h
// AppliaticsMobile
//
//  Created by Anping Wang on 3/31/12.
//  Copyright (c) 2012 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSImageView.h"

@protocol IconViewDelegate <NSObject>
@required
- (void) onSelect: (id) sender object: (id) item;
@end

@interface IconViewVC : UIViewController
{
    IBOutlet UILabel *textLabel;
    IBOutlet UILabel *subtitleLabel;
    IBOutlet SSImageView *imageView;
    IBOutlet UIButton *indicator;
    IBOutlet UILabel *sentiment;
    NSMutableArray *children;
    IBOutlet UIView *labelView;
    IBOutlet UIView *innerView;
    IBOutlet UIImageView *shadowImg;
}

@property NSInteger badges;
@property NSInteger mode;
@property NSInteger tag;

@property (nonatomic, strong) NSString * label;
@property (nonatomic, strong) NSString * subtitle;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * sentimentLabel;
@property (nonatomic, strong) UIColor * viewBG;
@property (nonatomic, strong) IconViewVC *parentIconView;

@property (nonatomic, strong) id<IconViewDelegate> iconViewDelegate;

//location in the grid
@property int row;
@property int col;

-(CGPoint) getCenter;

//
//object this icon represents. on select, this object is passed
//the delegate
@property (strong) id userInfo;

-(IBAction)onSelect:(id)sender;
- (void) updateUI;

//heirachical data structure
-(NSArray *) getChildren;
- (void) addChild:(id) child;
- (int) getLevel;

@end
