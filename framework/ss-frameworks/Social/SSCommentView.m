//
//  SSCommentView.m
//  SixStreams
//
//  Created by Anping Wang on 3/31/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCommentView.h"
#import "SSImageView.h"
#import "SSRoundTextView.h"
#import "SSStarRating.h"
#import "SSCommonVC.h"

@interface SSCommentView()
{
    __weak IBOutlet SSImageView *ivAuthor;
    __weak IBOutlet SSRoundTextView *tvComment;
    __weak IBOutlet SSStarRating *rating;
    __weak IBOutlet UILabel *lName;
}
@end
@implementation SSCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) assingComment:(id) comment
{
    ivAuthor.cornerRadius = ivAuthor.frame.size.width/2;
    ivAuthor.defaultImg = [UIImage imageNamed:@"people.png"];
    ivAuthor.url = [comment objectForKey:AUTHOR];
    tvComment.text = [comment objectForKey:COMMENT];
    rating.rating = [[comment objectForKey:RATING]floatValue];
    lName.text = [comment objectForKey:USER];
}

- (float) getHeight
{
    return 123;
}

@end
