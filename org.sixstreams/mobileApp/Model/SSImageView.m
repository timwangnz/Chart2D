//
//  SSImageView.m
//  Mappuccino
//
//  Created by Anping Wang on 4/12/13.
//  Copyright (c) 2013 TWC. All rights reserved.
//


#import "SSImageView.h"
#import "SSClient.h"
#import "QuartzCore/QuartzCore.h"
#import "DebugLogger.h"

@interface SSImageView ()  
{
    UIActivityIndicatorView *activityIndicator;

}

@end

@implementation SSImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         [self roundCorner];
    }
    return self;
}

- (void) roundCorner
{
    int width = self.frame.size.width;
    float corner = 4.0;
    if (width > 100 && width < 200)
    {
        corner = 6;
    }
    if (width >= 200)
    {
        corner = 10;
    }
    [self initBorder:self cornerRadius:corner];
}

-(void)initBorder :(UIView *) view cornerRadius:(float)cornerRadius
{
    CALayer *layer = view.layer;
    layer.cornerRadius = cornerRadius;
    layer.masksToBounds = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.defaultImg = self.image;
    [self roundCorner];
}

-(void) setUrl:(NSString *)url
{
    self.image = self.defaultImg;
    _url = url;
    
    if (url)
    {
        [self download:url];
    }
}

- (SSClient *) getClient
{
    return [[[SSClient getClient] setCachePolicy:@"enabled"] setTimeout:100];
}

- (void) download: (NSString *)uri
{
    if (!uri)
    {
        return;
    }
    
    NSData *cachedData = [[SSClient getClient] download: uri
                                             onCallback: ^(SSCallbackEvent *event)
     {
         if (event.error)
         {
             [self endLoading];
         }
         else if(event.callingStatus == SSEVENT_SUCCESS)
         {
             [self endLoading];
             UIImage *image = [UIImage imageWithData:event.data];
             if (image)
             {
                 self.image = image;
             }
             else
             {
                 DebugLog(@"Failed to load image data\n%@", event.uri);
             }
         }
     }
     ];
    if (cachedData)
    {
        self.image = [UIImage imageWithData:cachedData];
    }
    else
    {
        [self startLoading];
    }
}

- (void) startLoading
{
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
    [activityIndicator removeFromSuperview];
    activityIndicator = nil;
}

@end
