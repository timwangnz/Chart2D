//
//  SSSurveyCell.m
//  SixStreams
//
//  Created by Anping Wang on 7/28/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSSurveyCell.h"

@interface SSSurveyCell ()
{
    __weak IBOutlet UILabel *nameLabel;
}

@end

@implementation SSSurveyCell

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

- (IBAction)swiping:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    nameLabel.center = CGPointMake(location.x, nameLabel.center.y);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
 
-(void) updateCell:(id) item
{
    nameLabel.text = [item capitalizedString];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //self.scrollEnabled = YES;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //self.scrollEnabled = YES;
    //[super touchesCancelled:touches withEvent:event];
}
@end
