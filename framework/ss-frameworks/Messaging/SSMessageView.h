//
//  SSMessageView.h
//  SixStreams
//
//  Created by Anping Wang on 1/5/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSMessageView : UIView

@property (nonatomic, strong) id message;

- (id) initWithMessaage:(id)message withFrame:(CGRect)frame;

@end
