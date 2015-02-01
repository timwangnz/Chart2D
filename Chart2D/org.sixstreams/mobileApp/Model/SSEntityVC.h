//
//  SSCreateVC.h
//  Cars
//
//  Created by Anping Wang on 1/29/13.
//  Copyright (c) 2013 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSClientTableVC.h"
#import "SSPictureVC.h"
#import "SSSecurityVC.h"
#import "SSCommentVC.h"
#import "SSImageEditorVC.h"
#import "SSScrollView.h"

@class SSApp;

#define SECTION_GENERAL @"1.0General"
#define SECTION_PICTURES @"2.0Pictures"
#define SECTION_ACTIONS @"1.3Actions"
#define SECTION_COMMENTS @"9.4Comments"

@interface SSEntityVC : SSClientTableVC<UIActionSheetDelegate>
{
    
    NSMutableDictionary *tableData;
    IBOutlet UITableView *sectionTableView;
    
    NSArray *sortedKeys;
    
    BOOL changeIcon;
    int likes;
    IBOutlet UIButton *comment, *liked;
    IBOutlet UILabel *phone, *website, *email;
    IBOutlet SSImageView *avatar;
    IBOutlet SSScrollView *iconRoll;
    
    
    IBOutlet UIView *viewHeader;
    IBOutlet UIView *viewGeneral;
    IBOutlet UIView *viewActions;
    IBOutlet UIView *viewComments;
    IBOutlet UIView *viewPictures;
    
    IBOutlet UILabel *lLikes;
}

@property (strong, nonatomic) id entity;
@property (strong, nonatomic) NSString * entityType;
//objects
@property (retain, nonatomic) NSArray *objects;

@property BOOL editable;
@property (strong, nonatomic) SSApp *app;

- (void) setupUI;
- (NSString *) getHeaderText:(NSString *) sectionTitle;
- (void) setUpData;

//customization for cells in a section
- (CGFloat)heightForSection : (NSString *) section;
- (CGFloat)heightForRowInSection : (NSString *) section;
- (NSInteger)rowsForSection : (NSString *) section;
- (UITableViewCell *) cellForSection:(NSString *) section for:(UITableView *) tableView atRow:(int) row;

@end
