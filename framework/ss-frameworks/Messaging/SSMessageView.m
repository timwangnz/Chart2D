//
//  SSMessageView.m
//  SixStreams
//
//  Created by Anping Wang on 1/5/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSMessageView.h"
#import "SSRoundLabel.h"
#import "SSTableViewVC.h"
#import "SSSecurityVC.h"
#import "SSProfileVC.h"

@implementation SSMessageView


static int vMargin = 10;
static int hMargin = 10;
static int vMsgTop = 10;

- (id) initWithMessaage:(id)message withFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.message = message;
        SSRoundLabel *uiLabel = [[SSRoundLabel alloc]init];
        
        NSString *to = [message objectForKey:MESSAGE_TO];
        
        uiLabel.backgroundColor = [UIColor lightGrayColor];
        uiLabel.font = [UIFont systemFontOfSize:14];
        
        uiLabel.text = [NSString stringWithFormat:@" %@", [message objectForKey:MESSAGE]];
        uiLabel.frame = CGRectMake(2 ,10, 100, uiLabel.frame.size.height + vMargin);
        
        [uiLabel sizeToFit];
        
        if (uiLabel.frame.size.width > 150)
        {
            uiLabel.frame = CGRectMake(2 ,1, 150, uiLabel.frame.size.height + vMargin);
            //[uiLabel resizeToFit];
        }
        BOOL isFromMe = [to isEqualToString:[SSProfileVC profileId]];
        if (isFromMe)
        {
            uiLabel.textColor = [UIColor redColor];
            uiLabel.textAlignment = NSTextAlignmentLeft;
            uiLabel.frame = CGRectMake(2 ,vMsgTop + vMargin/2, uiLabel.frame.size.width + vMargin/2, uiLabel.frame.size.height + vMargin);
        }
        else
        {
            uiLabel.textColor = [UIColor blueColor];
            uiLabel.textAlignment = NSTextAlignmentLeft;
            uiLabel.frame = CGRectMake(self.frame.size.width -  uiLabel.frame.size.width - hMargin - 2,vMsgTop +  vMargin/2 ,uiLabel.frame.size.width + hMargin, uiLabel.frame.size.height + vMargin);
        }
        
        CGRect rect = self.frame;
        rect.origin.y = 0;
        rect.size.height = uiLabel.frame.size.height + vMsgTop + vMargin;
        
        self.frame = rect;
        
        UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(uiLabel.frame.origin.x ,5, uiLabel.frame.size.width, vMsgTop)];
        
        time.text = [[self.message objectForKey:CREATED_AT] since];
        time.font = [UIFont systemFontOfSize:8];
        time.textAlignment = isFromMe ? NSTextAlignmentLeft : NSTextAlignmentRight;
        [self addSubview:uiLabel];
        [self addSubview:time];
    }
    
    return self;
}




@end
