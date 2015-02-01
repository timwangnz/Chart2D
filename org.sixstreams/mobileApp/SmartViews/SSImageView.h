//
//  SSImageView.h
//  Mappuccino
//
//  Created by Anping Wang on 4/12/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSConnection.h"

@protocol SSImageViewDelegate <NSObject>
@optional
- (void) imageView:(id) imageView didLoadImage:(id) image;
- (void) imageView:(id) imageView didSelect:(id) image;
@end


@interface SSImageView : UIImageView

@property (nonatomic) NSString *attrName;//attrName for url
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *backupUrl;
@property (nonatomic) NSString *owner;

@property (nonatomic) id info;
@property (nonatomic) id<SSImageViewDelegate> delegate;

@property (nonatomic, weak) UIImage *defaultImg;
@property (nonatomic) float cornerRadius;
@property int transitionDuration;
@property BOOL isList;
@property BOOL isUrl;
@property BOOL serverImage;
@property BOOL imageChanged;

- (void) changeImage:(UIImage *) image;
- (void) changeImage:(UIImage *) image withOptions:(UIViewAnimationOptions ) options;
- (void) replaceUrl: (NSString *) url;
- (void) refreshImage;
@end
