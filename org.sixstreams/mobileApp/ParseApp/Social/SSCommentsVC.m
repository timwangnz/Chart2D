//
//  SSCommentsVC.m
//  SixStreams
//
//  Created by Anping Wang on 3/24/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSCommentsVC.h"
#import "SSFilter.h"
#import "SSImageView.h"
#import "SSStarRating.h"
#import "SSRoundView.h"
#import "SSRoundTextView.h"
#import "SSSecurityVC.h"
#import "SSCommentVC.h"

@interface SSCommentsVC ()
{
    IBOutlet UIButton *btnAddComment;
    IBOutlet UIView *vComments;
    IBOutlet UIView *popview;
    IBOutlet SSStarRating *ratingCtrl;
    IBOutlet UIButton *btnShowMore;
}

@property (strong, nonatomic) IBOutlet UILabel *lName;
@property (strong, nonatomic) IBOutlet SSRoundTextView *tvComment;
@property (strong, nonatomic) IBOutlet SSImageView *mvIcon;
@property (strong, nonatomic) IBOutlet UILabel *lCount;

@end

@implementation SSCommentsVC

- (IBAction)addComment:(id)sender
{
    [SSSecurityVC checkLogin:self withHint:@"Signin"
                  onLoggedIn:^(id user) {
                      if (user){
                          SSCommentVC *commentEditorVC = [[SSCommentVC alloc]init];
                          commentEditorVC.item2Comment = self.itemCommented;
                          commentEditorVC.objectType = self.itemType;
                          commentEditorVC.titleKey = self.titleKey;
                          commentEditorVC.title = @"Add Comments";
                          [self.navigationController pushViewController:commentEditorVC animated:YES];
                      }
                  }];
}

- (IBAction)showMoreComments:(id)sender {
    [self popView:popview];
}

- (IBAction)dismissView:(id)sender {
    [self dissmissView:popview];
}

- (void) setupInitialValues
{
    [super setupInitialValues];
    self.objectType = SOCIAL_COMMENT;
    self.orderBy = CREATED_AT;
    self.ascending = NO;
}

- (float) getHeight:(id) comment
{
    NSString *commentTxt = [comment objectForKey:COMMENT];
    CGRect r = [commentTxt boundingRectWithSize:CGSizeMake(276, 0)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                        context:nil];
    return r.size.height;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id comment = [self.objects objectAtIndex:indexPath.row];
    float height =  [self getHeight:comment]+60;
    return height;
}

- (void) viewWillAppear:(BOOL)animated
{
    ratingCtrl.starImage = [UIImage imageNamed:@"star-template"];
    ratingCtrl.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"]
                                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [ratingCtrl setNeedsDisplay];
    
    ratingCtrl.rating = 4;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.objects count] == 0)
    {
        return 0;
    }
    return [self.objects count];
}

#define CELL @"cell"
- (UIView *) tableView:(UITableView *)tableView cell:(UITableViewCell *) cell row:(int) row col:(int) col
{
    id item  = [self.objects objectAtIndex:row];
    
    UIView *view = [[UIView alloc]initWithFrame:cell.contentView.frame];
    NSString *cellText = [item objectForKey:COMMENT];
    UITextView *uiLabel = [[SSRoundTextView alloc]init];
    [uiLabel setUserInteractionEnabled:NO];

    uiLabel.editable = NO;
    uiLabel.scrollEnabled = NO;
    
    uiLabel.text = cellText;
    
    uiLabel.backgroundColor = [UIColor clearColor];
    uiLabel.textColor = [UIColor grayColor];
    uiLabel.font = [UIFont systemFontOfSize:14];
    
    uiLabel.frame = CGRectMake(2 ,2, 276, [self getHeight:item]+20);
    
    SSImageView *authorIcon = [[SSImageView alloc]init];
    authorIcon.cornerRadius = 12;
    authorIcon.frame = CGRectMake(10, uiLabel.frame.size.height + 10, 24, 24);
    authorIcon.url = [item objectForKey:AUTHOR];
    UILabel *lName = [[UILabel alloc]initWithFrame:CGRectMake(40, uiLabel.frame.size.height + 5, 100, 20)];
   
    UILabel *lDate = [[UILabel alloc]initWithFrame:CGRectMake(40,uiLabel.frame.size.height + 20, 100, 20)];
    lDate.font = lName.font =[UIFont systemFontOfSize:10];
    lDate.textColor = lName.textColor = [UIColor grayColor];
    
    lName.text = [item objectForKey:USER];
    
    lDate.text = [[item objectForKey:CREATED_AT] since];
    
    [view addSubview:lName];
    [view addSubview:authorIcon];
    [view addSubview:lDate];
    [view addSubview:uiLabel];
    return view;
}

-(void) onDataReceived:(id)objects
{
    [super onDataReceived:objects];
    vComments.hidden = [objects count] == 0;
    if (!vComments.hidden)
    {
        btnAddComment.center = CGPointMake(self.view.center.x, 170);
        id item = [objects objectAtIndex:0];
        self.lCount.text = [NSString stringWithFormat:@"Total %d Comment%@", (int)[objects count], [objects count] == 1 ? @"" : @"s"];
        self.mvIcon.cornerRadius = self.mvIcon.frame.size.width/2;
        self.mvIcon.defaultImg = [UIImage imageNamed:@"people.png"];
        self.mvIcon.url = [item objectForKey:AUTHOR];
        ratingCtrl.rating = [[item objectForKey:RATING]floatValue];
        self.tvComment.text = [item objectForKey:COMMENT];
        self.tvComment.textColor = self.lCount.textColor;
        [self.tvComment autofit];
        self.view.frame = CGRectMake(0, 0 , self.view.frame.size.width, self.tvComment.frame.size.height + 105);
        self.lName.text = [item objectForKey:USER];
        btnShowMore.hidden = [objects count] < 2;
    }
    else{
        self.view.frame = CGRectMake(0, 0 , self.view.frame.size.width, 100);
        btnAddComment.center = self.view.center;
        [btnAddComment setTitle:@"Be the first to comment" forState:UIControlStateNormal];
    }
}



@end
