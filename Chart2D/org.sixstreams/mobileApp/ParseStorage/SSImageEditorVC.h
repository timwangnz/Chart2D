//
//  ImagePickerViewController.h
//  iSwim2.0
//
//  Created by Anping Wang on 3/17/11.
//  Copyright 2011 s. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCommonVC.h"

@protocol ProcessImageDelegate <NSObject>
@optional
- (void) processImage: (UIImage *)image;
- (void) processVideo: (id) video;
@end


@interface SSImageEditorVC : SSCommonVC  <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) id<ProcessImageDelegate> processImageDelegate;
@property int scale2Size;
@property (nonatomic, strong) UIColor *background;
@property (nonatomic, strong) SSCommonVC *fromVC;

- (IBAction) saveImage: (id) sender;

- (void) editImage :(UIImage *) anImage;
- (IBAction) pickFromLib :(id) sender;
- (IBAction) takePhoto :(id) sender;


+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;

@end
