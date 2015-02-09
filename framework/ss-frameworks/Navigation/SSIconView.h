//
// AppliaticsIconView.h
// Appliatics
//
//  Created by Anping Wang on 9/25/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSRoundView.h"
#import "SSImageView.h"
/**
    Represents a type of objecct shown in the container view. When use click on this icon, it shows the list of objects
 **/
@class SSIconView;

@protocol SSIconViewDelegate <NSObject>
@required
- (void) iconView:(SSIconView *) view itemSelected:(id) item;
@end


@interface SSIconView : SSRoundView
{
    IBOutlet UILabel *titleLabel;
    IBOutlet SSImageView *imageView;
    IBOutlet UIButton *badgesIndicator;
}

@property int badges;
@property int mode;
@property int count;
@property BOOL selected;

@property (nonatomic, strong) UIViewController *listVC;
@property (nonatomic, strong) id subscription;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) id<SSIconViewDelegate>  delegate;

- (IBAction) open:(id)sender;
- (void) updateUI;

@end
