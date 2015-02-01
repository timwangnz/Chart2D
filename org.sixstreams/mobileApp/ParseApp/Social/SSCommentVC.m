//
//  SSCommentVC.m
//  SixStreams
//
//  Created by Anping Wang on 3/23/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCommentVC.h"
#import "SSProfileVC.h"
#import "SSStarRating.h"
#import "SSApp.h"
#import "SSJSONUtil.h"

@interface SSCommentVC ()<SSStarRatingProtocol>
{
    IBOutlet UITextView *tvComment;
    IBOutlet SSStarRating *ratingCtrl;
}

@property (weak, nonatomic) IBOutlet UILabel *lName2CommentOn;

@end

@implementation SSCommentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lName2CommentOn.text =
    [[SSApp instance] value : self.item2Comment forKey:self.self.titleKey ? self.titleKey : NAME];
    
    self.itemType = SOCIAL_COMMENT;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ratingCtrl.delegate = self;
    ratingCtrl.tintColor =[UIColor redColor];
    ratingCtrl.horizontalMargin = 6;
    ratingCtrl.backgroundColor = [UIColor whiteColor];
}

- (void) uiWillUpdate:(id)object
{
    tvComment.text = [self.item2Edit objectForKey:COMMENT];
    
    _lName2CommentOn.text = [self.item2Comment valueForPath:self.titleKey];
    
    ratingCtrl.rating = [[self.item2Edit objectForKey:RATING] floatValue];
}

- (void) entityWillSave:(id) object
{
    [object setValue:tvComment.text forKey:COMMENT];
    [object setValue:[self.item2Comment objectForKey:REF_ID_NAME] forKey:COMMENTED_ON];
    [object setValue: [NSNumber numberWithInt:ratingCtrl.rating] forKey:RATING];
    [object setValue: [SSConnection objectType:self.objectType] forKey:CONTEXT_TYPE];
    [object setValue: [[SSApp instance] contextualObject:self.item2Comment ofType:self.objectType] forKey:CONTEXT];
}

-(void)starsSelectionChanged:(SSStarRating*)control rating:(float)rating
{
    [self.item2Edit setValue:[NSNumber numberWithFloat:rating] forKey:RATING];
}

@end
