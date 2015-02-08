//
//  SSTexture.m
//  SixStreams
//
//  Created by Anping Wang on 3/8/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//
#import <GLKit/GLKit.h>

#import "SSTexture.h"

@interface SSTexture()
{
    GLuint texture;
}
@end

@implementation SSTexture

- (id) init
{
    self = [super init];
    deltaY = deltaY =0.0;
    self.isResizable = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"texture" ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    self.background = [[UIImage alloc] initWithData:texData];
   
    UIImage* image =  self.background;
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    GLuint width = (GLuint) CGImageGetWidth(image.CGImage);
    GLuint height = (GLuint) CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    
    CGContextRef bContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( bContext, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( bContext, 0, height - height );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    CGContextDrawImage( bContext, CGRectMake( 0, 0, width, height ), image.CGImage );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    CGContextRelease(bContext);
    glBindTexture(GL_TEXTURE_2D, 0);
    free(imageData);
    
    return self;
}

- (void) updateModel
{
   
}

- (void) draw
{
    [self updateModel];
    [self fillWithTexture];
}

- (void)fillWithTexture
{
      /*
    CGPoint firstPoint = CGPointMake(self.start.x + deltaX, self.start.y + deltaY);
    CGPoint lastPoint = CGPointMake(self.end.x + deltaX, self.end.y + deltaY);
   
    GLfloat texSize = 1.0f;
    GLint size[4] = {1,2,2,2};
    glGetIntegerv(GL_VIEWPORT, size);
    
    GLfloat squareVertices[] =
    {
        lastPoint.x, size[3] - lastPoint.y,
        firstPoint.x,  size[3] -lastPoint.y,
        lastPoint.x,  size[3] -firstPoint.y,
        firstPoint.x,   size[3] - firstPoint.y,
    };
    
    GLfloat texCoords[] = {
        0.0, texSize,
        texSize, texSize,
        0.0, 0.0,
        texSize, 0.0
    };
    
    UIColor *color = self.isSelected ? [UIColor lightGrayColor] : self.color;
    
    size_t numComponents = CGColorGetNumberOfComponents([color CGColor]);
    const CGFloat *components = CGColorGetComponents([color CGColor]);
  
    if (numComponents == 4)
    {
        glColor4f(components[0], components[1], components[2], components[3]);
    }
    else if(numComponents == 2)
    {
        glColor4f(components[0], components[0], components[0], components[1]);
    }
    else
    {
        glColor4f(1.0, 1.0, 0.0, 1.0);
    }
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    */
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    //glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
