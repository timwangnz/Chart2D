//
//  CheckBox.m
// Appliatics
//
//  Created by Anping Wang on 10/2/13.
//

#import "SSCheckBox.h"

@implementation SSCheckBox

- (void) setup
{
    [self setImage:[UIImage imageNamed:@"check-selected"] forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"check-unselected"] forState:UIControlStateNormal];
    
    //[self setBackgroundImage:[UIImage imageNamed:@"checkboxbg"] forState:UIControlStateSelected];
    //[self setBackgroundImage:[UIImage imageNamed:@"checkboxbg"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(checkboxClicked:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
}

- (void) checkboxClicked:(SSCheckBox *) sender
{
    [sender setSelected:!sender.selected];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}
@end
