//
//  EDStartRatingView.
//
//  Created by Ernesto Garcia on 26/02/12.
//  Copyright (c) 2012 cocoawithchurros.com All rights reserved.
//  Distributed under MIT license

#import "SSStarRating.h"

#define ED_DEFAULT_HALFSTAR_THRESHOLD   0.6


@interface SSStarRating()
@property (nonatomic,strong ) UIImage *tintedStarImage;
@property (nonatomic,strong ) UIImage *tintedStarHighlightedImage;
@property (nonatomic) CGColorRef backCGColor;
@end


@implementation SSStarRating
@synthesize starImage;
@synthesize starHighlightedImage;
@synthesize rating=_rating;
@synthesize maxRating;
@synthesize backgroundImage;
@synthesize editable;
@synthesize delegate=_delegate;
@synthesize horizontalMargin;
@synthesize halfStarThreshold;
@synthesize displayMode;
@synthesize returnBlock=_returnBlock;

#pragma mark -
#pragma mark Init & dealloc


-(void)setDefaultProperties
{
    self.starImage = [UIImage imageNamed:@"star-template.png"];
    self.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    maxRating = 5.0;
    horizontalMargin = 2;
    editable=YES;
    _rating= 2.5;
    displayMode = SSStarRatingDisplayFull;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self setDefaultProperties];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        [self setDefaultProperties];
    }
    return self;
}

#pragma mark -
#pragma mark Setters
-(void)setReturnBlock:(SSStarRatingReturnBlock)retBlock
{
    _returnBlock = [retBlock copy];
    _delegate = nil;
}

-(void)setDelegate:(id<SSStarRatingProtocol>)delegate
{
    _delegate = delegate;
    _returnBlock = nil;
}

-(void)setRating:(float)ratingParam
{
    _rating = ratingParam;
    [self setNeedsDisplay];
}

-(void)setDisplayMode:(SSStarRatingDisplayMode)dispMode
{
    displayMode = dispMode;
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing
-(CGPoint)pointOfStarAtPosition:(NSInteger)position highlighted:(BOOL)hightlighted
{
    CGSize size = hightlighted?starHighlightedImage.size:starImage.size;
    
    NSInteger starsSpace = self.bounds.size.width - 2*horizontalMargin;
    
    NSInteger interSpace = 0;
    interSpace = maxRating-1>0?(starsSpace - (maxRating)*size.width)/(maxRating-1):0;
    if( interSpace <0 )
        interSpace=0;
    CGFloat x = horizontalMargin + size.width*position;
    if( position >0 )
        x+=interSpace*position;
    CGFloat y = (self.bounds.size.height - size.height)/2.0;
    return CGPointMake(x  ,y); 
}

-(void)drawBackgroundImage
{
    if( backgroundImage )
    {
        [backgroundImage drawInRect:self.bounds];
    }
    
}

-(void)drawImage:(UIImage*)image atPosition:(NSInteger)position
{
    [image drawAtPoint:[self pointOfStarAtPosition:position highlighted:YES]];
}

-(void)setBackgroundColor:(UIColor *)color
{

    [super setBackgroundColor:color];
    if( color )
    {
        self.backCGColor = [self cgColor:color];
    }
}

-(CGColorRef)cgColor:(UIColor*)color
{
    CGColorRef cgColor = nil;
    cgColor  = color.CGColor;
    return cgColor;
}

-(CGContextRef)currentContext
{
    CGContextRef ctx=nil;
    ctx = UIGraphicsGetCurrentContext();
    return ctx;
}

-(void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    CGContextRef ctx = [self currentContext];  
    
    // Fill background color
    CGContextSetFillColorWithColor(ctx, self.backCGColor);
    CGContextFillRect(ctx, bounds);
    
    // Draw background Image
    if( backgroundImage )
    {
        [self drawBackgroundImage];
    }
    
    // Draw rating Images
    CGSize starSize = starHighlightedImage.size;
    for( NSInteger i=0 ; i<maxRating; i++ )
    {
        [self drawImage:self.tintedStarImage atPosition:i];
        if( i < _rating )   // Highlight
        {
            CGContextSaveGState(ctx);
            {
                if( i< _rating &&  _rating < i+1 )
                {
                    
                    CGPoint starPoint = [self pointOfStarAtPosition:i highlighted:NO];
                    float difference = _rating - i;
                    CGRect rectClip;
                    rectClip.origin = starPoint;
                    rectClip.size = starSize;
                    if( displayMode == SSStarRatingDisplayHalf && difference < halfStarThreshold )    // Draw half star image
                    {
                        rectClip.size.width/=2.0;
                    }
                    else if( displayMode == SSStarRatingDisplayAccurate )
                    {
                        rectClip.size.width*=difference;
                    }
                    else {
                        rectClip.size.width = 0;
                    }
                    if( rectClip.size.width >0 )
                        CGContextClipToRect( ctx, rectClip);
                    
                }
                
                [self drawImage:self.tintedStarHighlightedImage atPosition:i];
            }
            CGContextRestoreGState(ctx);
        }
    }
    
}


#pragma mark -
#pragma mark Mouse/Touch Interaction
-(float) starsForPoint:(CGPoint)point
{
    float stars=0;
    for( NSInteger i=0; i<maxRating; i++ )
    {
        CGPoint p =[self pointOfStarAtPosition:i highlighted:NO];
        if( point.x > p.x )
        {
            float increment=1.0;
            
            if( self.displayMode == SSStarRatingDisplayHalf  )
            {
                float difference = (point.x - p.x)/self.starImage.size.width;
                if( difference < self.halfStarThreshold )
                {
                    increment=0.5;
                }
            }
            stars+=increment;
        }
    }
    return stars;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if( !editable )
        return;

    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    self.rating =[self starsForPoint:touchLocation];
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !editable )
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    self.rating =[self starsForPoint:touchLocation]; 
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( !editable )
        return;
    
    if( self.delegate && [self.delegate respondsToSelector:@selector(starsSelectionChanged:rating:)] )
        [self.delegate starsSelectionChanged:self rating:self.rating];
    
    if( self.returnBlock)
        self.returnBlock(self.rating);
    
}

#pragma mark - Tint color Support
-(void)setStarImage:(UIImage *)image
{
    if( starImage == image)
        return;
    starImage = image;
    self.tintedStarImage = [self tintedImage:image];
}

-(void)setStarHighlightedImage:(UIImage *)image
{
    if( starHighlightedImage == image )
        return;
    starHighlightedImage = image;
    self.tintedStarHighlightedImage = [self tintedImage:image];

}
-(UIImage*)tintedImage:(UIImage*)img
{
    UIImage *tintedImage = img;
    if( [self respondsToSelector:@selector(tintColor)] && img.renderingMode == UIImageRenderingModeAlwaysTemplate )
    {
        UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale );
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, img.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
        // draw alpha-mask
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGContextDrawImage(context, rect, img.CGImage);
        // draw tint color, preserving alpha values of original image
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        [self.tintColor setFill];
        CGContextFillRect(context, rect);
        
        tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return tintedImage;
}


@end
