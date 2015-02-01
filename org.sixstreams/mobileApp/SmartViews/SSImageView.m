//
//  SSImageView.m
//  Mappuccino
//
//  Created by Anping Wang on 4/12/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//
#import "SSImageView.h"
#import "SSConnection.h"

#import "QuartzCore/QuartzCore.h"
#import "DebugLogger.h"
#import "SSSecurityVC.h"

@interface SSImageView ()  
{
    UIActivityIndicatorView *activityIndicator;
    BOOL ended;
    NSString *currentObjectId;
}

@end

@implementation SSImageView


- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self roundCorner];
    }
    return self;
}

- (void) setCornerRadius:(float)cornerRadius
{
    _cornerRadius = cornerRadius;
    [self roundCorner];
}

- (void) roundCorner
{
    [self initBorder:self cornerRadius:self.cornerRadius];
}

-(void)initBorder :(UIView *) view cornerRadius:(float)cornerRadius
{
    CALayer *layer = view.layer;
    layer.cornerRadius = cornerRadius;
    layer.masksToBounds = YES;
}

- (void) changeImage:(UIImage *) newImage
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (self.transitionDuration == 0)
        {
            self.contentMode = UIViewContentModeScaleAspectFill;
            self.image = newImage;
        }
        else
        {
            [self changeImage:newImage withOptions:UIViewAnimationOptionTransitionCrossDissolve];
        }
    }];
}

- (void) changeImage:(UIImage *) newImage withOptions:(UIViewAnimationOptions ) options
{
    self.contentMode = UIViewContentModeScaleAspectFill;
    [UIView transitionWithView:self
                      duration:self.transitionDuration
                       options:options
                    animations:^{
                        self.image = newImage;
                    } completion:nil];
   
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _defaultImg = self.image;
    [self roundCorner];
}

- (void) refreshImage
{
    UIImage *cached = [cachedImages objectForKey:self.url];
    if (cached) {
        self.image = [cached isEqual:[NSNull null]] ? nil : cached;
    }
}

- (void) replaceUrl : (NSString *) url
{
    if(_url)
    {
        [cachedImages removeObjectForKey:_url];
    }
    self.url = url;
}

-(void) setUrl:(NSString *)url
{
    if ([_url isEqualToString:url]) {
        UIImage *cached = [cachedImages objectForKey:url];
        if (cached) {
            self.image = [cached isEqual:[NSNull null]] ? nil : cached;
            if(self.delegate && [self.delegate respondsToSelector:@selector(imageView:didLoadImage:)])
            {
                [self.delegate imageView:self didLoadImage:cached];
            }
            return;
        }
    }
    
    if (url)
    {
        _url = url;
        [self download:url];
    }
}

static id cachedImages;

- (void) download: (NSString *)uri
{
    if (!uri)
    {
        return;
    }
    
    if (nil == cachedImages)
    {
        cachedImages = [NSMutableDictionary dictionary];
    }
    
    UIImage *cached = [cachedImages objectForKey:uri];
    if (cached)
    {
        self.image = [cached isEqual:[NSNull null]] ? nil : cached;
        if(self.delegate && [self.delegate respondsToSelector:@selector(imageView:didLoadImage:)])
        {
            [self.delegate imageView:self didLoadImage:self.image];
        }
        return;
    }
    
    SSConnection *conn = [SSConnection connector];
    ended = NO;
    if (self.isUrl)
    {
        [conn downloadFile:self.url onSuccess:^(NSData *data) {
            [self processData:data on:uri];
            [self endLoading];
        } onFailure:^(NSError *error) {
            [self endLoading];
        }];
    }
    else
    {
        [conn downloadData:uri
                   forUser:self.owner
                 onSuccess:^(NSData *data) {
                     if (data && ![data isEqual:[NSNull null]]){
                         [self processData:data on:uri];
                     }
                     else
                     {
                         if (self.backupUrl == nil || [uri isEqualToString:self.backupUrl])
                         {
                             self.image = self.defaultImg;
                             if(self.delegate && [self.delegate respondsToSelector:@selector(imageView:didLoadImage:)])
                             {
                                 [self.delegate imageView:self didLoadImage:nil];
                             }
                             
                         }
                         else
                         {
                             [self download:self.backupUrl];
                         }
                         
                     }
                     [self endLoading];
                 } onFailure:^(NSError *error) {
                     [self endLoading];
                 }];
    }
    [self performSelector:@selector(startLoading) withObject:NULL afterDelay:0.4];
}

- (void) processData:(NSData *) data on:(NSString *) uri
{
    __block UIImage *imageTobeCreated;
    if (data && ![data isEqual:[NSNull null]])
    {
        self.image = nil;
        imageTobeCreated = [UIImage imageWithData:data];
        if (!imageTobeCreated)
        {
            self.image = self.defaultImg;
        }
        else
        {
            [cachedImages setObject:imageTobeCreated forKey:uri];
            [self changeImage:imageTobeCreated];
            self.serverImage = YES;
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(imageView:didLoadImage:)])
        {
            [self.delegate imageView:self didLoadImage:imageTobeCreated];
        }
    }
    data = nil;
}

- (void) startLoading
{
    if (ended)
    {
        return;
    }
    if (!activityIndicator)
    {
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.alpha = 1.0;
        activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        activityIndicator.hidesWhenStopped = NO;
        [self addSubview:activityIndicator];
    }
    [activityIndicator startAnimating];
}

- (void) endLoading
{
    ended = YES;
    if(activityIndicator)
    {
        [activityIndicator removeFromSuperview];
        activityIndicator = nil;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self] anyObject];
    if ([touch tapCount] == 1)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(imageView:didSelect:)])
        {
            [self.delegate imageView:self didSelect:self.image];
        }
    }
}

@end
