//
//  SSImageView.h
//  Mappuccino
//
//  Created by Anping Wang on 4/12/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSImageView : UIImageView

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) UIImage *defaultImg;
@end
