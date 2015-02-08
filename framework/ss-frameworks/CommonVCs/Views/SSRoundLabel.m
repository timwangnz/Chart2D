//
//  RoundLabel.m
// Appliatics
//
//  Created by Anping Wang on 9/16/13.
//  Copyright (c) 2013 Anping Wang. All rights reserved.
//

#import "SSRoundLabel.h"
#import <CoreText/CoreText.h>

@implementation SSRoundLabel

- (void) drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
    
    if(self.showShadow)
    {
        layer.masksToBounds = NO;
        layer.cornerRadius = 8; // if you like rounded corners
        layer.shadowOffset = CGSizeMake(2, 2);
        layer.shadowRadius = 2;
        layer.shadowOpacity = 0.4;
    }
    else
    {
        float corner = self.cornerRadius == 0 ? 6 : self.cornerRadius;
        if (self.tag != 0)
        {
            corner = self.tag;
        }
        layer.cornerRadius = corner;
        layer.masksToBounds = YES;
    }
    [super drawRect:rect];
}


-(CGFloat)resizeToFit{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(CGFloat)expectedHeight{
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByWordWrapping];
    CGSize expectedLabelSize = [[self text] boundingRectWithSize:CGSizeMake(self.frame.size.width, 2000.0)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName : self.font}
                                                         context:nil].size;
    return expectedLabelSize.height;
}

- (void)_drawRectMulti:(CGRect)rect
{
	// create a font, quasi systemFontWithSize:24.0
	CTFontRef sysUIFont = CTFontCreateWithName((__bridge_retained CFStringRef)self.font.fontName, self.font.pointSize,NULL);
    
	// create a naked string
	NSString *string = self.text;
    
	CGColorRef color = self.textColor.CGColor;
    
	// now for the actual drawing
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	// flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    CTTextAlignment theAlignment = NSTextAlignmentToCTTextAlignment(self.textAlignment);
	CFIndex theNumberOfSettings = 2;
	CTParagraphStyleSetting theSettings[2] =
	{
		{ kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment),
			&theAlignment},
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &_multiLineSpacing}
	};
	
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(theSettings, theNumberOfSettings);
	
	NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
									(__bridge id)(sysUIFont), (NSString *)kCTFontAttributeName,
									(__bridge id)color, (NSString *)kCTForegroundColorAttributeName,
									paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
									nil];
	
	
	NSAttributedString *stringToDraw = [[NSAttributedString alloc] initWithString:string attributes:attributesDict];
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)stringToDraw);
	
	//Create Frame
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathAddRect(path, NULL, rect);
	
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
	
	//Draw Frame
	CTFrameDraw(frame, context);
	
	//Release all retained objects
	
	CFRelease(path);
	CFRelease(sysUIFont);
}
@end
