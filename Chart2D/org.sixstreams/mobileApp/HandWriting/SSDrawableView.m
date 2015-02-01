//
//  GLView.m
//  Anping Wang
//
//  Created by Anping Wang on 11/1/12.
//  Copyright (c) 2012 s. All rights reserved.
//
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "SSDrawableView.h"
#import "GLPen.h"
#import "SSLinePoint.h"
#import "SSLine.h"
#import "SSShape.h"
#import "SSConnection.h"
#import "ParseStorageHeader.h"
#import "SSProfileVC.h"
#import "SSGraph.h"

@interface SSDrawableView()
{
    // The pixel dimensions of the backbuffer
    
	GLint   backingWidth;
	GLint   backingHeight;
    
    //GLuint	brushTexture;
	EAGLContext *context;
    
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer, depthRenderbuffer;
    
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint msaaFramebuffer, msaaRenderBuffer, msaaDepthBuffer;
        
    UIImage *backgroundImg;
   
    BOOL inReplay;
    
    SSTool *selectedTool;
    BOOL clearBufferRequired;
    //
    UIScreen *_targetScreen;
    CADisplayLink *_displayLink;
    BOOL _zeroDeltaTime;
    NSInteger _animationFrameInterval;
}

- (BOOL)createFramebuffer;
- (void)destroyFramebuffer;

@end


@implementation SSDrawableView

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
	{
		_animating = FALSE;
        _animationFrameInterval = 1;
		_displayLink = nil;
        
        _zeroDeltaTime = TRUE;
        
        self.gridColor = [UIColor blueColor];
        self.gridWidth = -1;
        self.gridHeight = 40;
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            
        }
        [self setupContext];
    }
    return self;
}

- (void) setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    if(self.graph.hasSelection)
    {
        for(SSShape *shape in [self.graph selecedShapes] )
        {
            shape.color = selectedColor;
        }
        [self redraw];
        [self redraw];
    }
    
}
- (void) setSelectedWidth:(float)selectedWidth
{
    _selectedWidth = selectedWidth;
    if(self.graph.hasSelection)
    {
        for(SSShape *shape in [self.graph selecedShapes] )
        {
            shape.penWidth = selectedWidth;
        }
        [self redraw];
    }
   
}

- (void) addImage:(UIImage *) image at:(CGPoint *) point
{
    backgroundImg = image;
}

- (void) setGraph:(SSGraph *)graph
{
    if (_graph)
    {
        [_graph save];
    }
    _graph = graph;
    graph.inView = self;
    clearBufferRequired = YES;
    
    self.readonly = graph.readonly;
    [self setNeedsLayout];
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
// If our view is resized, we'll be asked to layout subviews.
// This is the perfect opportunity to also update the framebuffer so that it is
// the same size as our display area.

-(void)layoutSubviews
{
    //clearBufferRequired = YES;
	[self destroyFramebuffer];
    [self createFramebuffer];
    
    [self draw];
}

- (void) setupContext
{
    // Set the view's scale factor
    self.contentScaleFactor = 1.0;
    // Setup OpenGL states
    glDisable(GL_DITHER);
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);

    CGRect frame = self.bounds;
    CGFloat scale = self.contentScaleFactor;
    
    // Setup the view port in Pixels
    glMatrixMode(GL_PROJECTION);
    glOrthof(0, frame.size.width * scale, 0, frame.size.height * scale, -1, 1);
    glViewport(0, 0, frame.size.width * scale, frame.size.height * scale);
    
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_BLEND);
 
    glBlendFunc(GL_ONE, GL_SRC_COLOR);
    glEnable(GL_POINT_SPRITE_OES);
    glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
    
}

- (BOOL)createFramebuffer
{
	glGenFramebuffersOES(1, &viewFramebuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable: (CAEAGLLayer*)self.layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    [self setupDepthWithMultiSampling:YES];
    
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}
	return YES;
}

- (void) setupDepthWithMultiSampling:(BOOL) multisample
{
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT24_OES, backingWidth, backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    glEnable(GL_DEPTH_TEST);
    
    if (multisample)
    {
        GLint maxSamplesAllowed;
        glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamplesAllowed);
        int samplesToUse = maxSamplesAllowed;
        
        glGenFramebuffersOES(1, &msaaFramebuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
        
        glGenRenderbuffersOES(1, &msaaRenderBuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaRenderBuffer);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, samplesToUse, GL_RGBA8_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, msaaRenderBuffer);
        
        int depthBits = 0;
        if (depthBits > 0)
        {
            glGenRenderbuffersOES(1, &msaaDepthBuffer);
            glBindRenderbufferOES(GL_RENDERBUFFER_OES, msaaDepthBuffer);
            
            glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER_OES, samplesToUse, GL_DEPTH_COMPONENT24_OES, backingWidth, backingHeight);
            glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, msaaDepthBuffer);
        }
    }
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
    if(depthRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
    
    if(msaaFramebuffer)
    {
        glDeleteFramebuffersOES(1, &msaaFramebuffer);
        msaaFramebuffer = 0;
 
        const GLenum discards[]  = {GL_COLOR_ATTACHMENT0,GL_DEPTH_ATTACHMENT};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,2,discards);
    }
    
	if (msaaRenderBuffer)
    {
        glDeleteRenderbuffersOES(1, &msaaRenderBuffer);
        msaaRenderBuffer = 0;
	}
	
    if(msaaDepthBuffer)
	{
		glDeleteRenderbuffersOES(1, &msaaDepthBuffer);
		msaaDepthBuffer = 0;
	}
}

- (void) flushContext
{
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);	// Render the vertex array
    if(msaaFramebuffer)
    {
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, msaaFramebuffer);
        glResolveMultisampleFramebufferAPPLE();
	}
    
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    // Display the buffer
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

#pragma undo redo

- (BOOL) isUndoable
{
    return [self.graph isUndoable];
}

- (BOOL) isRedoable
{
    return [self.graph isUndoable];
}

//return YES if undo operation is success, otherwise NO

- (void) redraw
{
    [self eraseBuffer];
    [self draw];
    [self flushContext];
}

- (void) draw
{
    if (clearBufferRequired)
    {
        [self eraseBuffer];
    }
    
    if(self.showGrid)
    {
        [self drawGrid];
    }
    [self.graph draw];
    [self flushContext];
}

- (void) drawGridLine:(CGPoint) start to:(CGPoint) end
{
    static GLfloat* vertexBuffer = NULL;
    
	if(vertexBuffer == NULL)
	{
		vertexBuffer = malloc(4 * sizeof(GLfloat));
	}
    vertexBuffer[0] = start.x;
    vertexBuffer[1] = start.y;
	vertexBuffer[2] = end.x;
    vertexBuffer[3] = end.y;
    
	glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
    glDrawArrays(GL_LINES, 0, 2);
    
}

- (void) drawGrid
{
    CGFloat start = 0;
    glLineWidth(0.1);
    size_t numComponents = CGColorGetNumberOfComponents([self.gridColor CGColor]);
    const CGFloat *components = CGColorGetComponents([self.gridColor CGColor]);
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
    
    if (self.gridHeight > 0)
    {
        for(int i= 0 ; start < self.bounds.size.height; i++)
        {
            start = (i)*self.gridHeight;
            
            CGPoint startPt = CGPointMake(0, start);
            CGPoint toPt = CGPointMake(self.bounds.size.width, start);
            [self drawGridLine:startPt to:toPt];
        }
    }
    if (self.gridWidth > 0)
    {
        start = 0;
        for(int i= 0; start < self.bounds.size.width; i++)
        {
            start = (i)*self.gridWidth;
            CGPoint startPt = CGPointMake(start, 0);
            CGPoint toPt = CGPointMake(start, self.bounds.size.height);
            [self drawGridLine:startPt to:toPt];
        }
    }
}

//this will remove server objects
- (void) clearDrawing
{
    [self.graph clear];
    [self cleanup];
    [self layoutSubviews];
}

- (void) cleanup
{
    [self.graph removeAllShapes];
}

- (void) eraseBuffer
{
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue =0;
    CGFloat alpha = 1;
    
    [self.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    if (msaaFramebuffer)
    {
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, msaaFramebuffer);
        //glViewport(0, 0, backingWidth, backingHeight);
        glClearColor(red, green, blue, alpha);
        glClear(GL_COLOR_BUFFER_BIT |GL_DEPTH_BUFFER_BIT);
    }
    else
    {
        glClearColor(red, green, blue, alpha);
        glClear(GL_COLOR_BUFFER_BIT);
    }
}

- (double) distFrom:(CGPoint) p1 to:(CGPoint) p2
{
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.readonly|| self.graph == nil)
    {
        return;
    }
    
    if([touches count]>1)
    {
        //we are not doing multi touch for now
        return;
    }
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    selectedTool = [SSTool getTool:self.tool];
    selectedTool.penColor = self.selectedColor;
    selectedTool.penWidth = self.selectedWidth;
    [selectedTool startCreateShape:[touch locationInView:self] forGroup:self.graph];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.readonly || self.graph == nil)
    {
        return;
    }
    if([touches count]>1)
    {
        //we are not doing multi touch for now
        return;
    }
	UITouch* touch = [[event touchesForView:self] anyObject];
    //Set moveTo
    [selectedTool duringCreateShape:[touch locationInView:self] forGroup:self.graph];
    [self draw];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.isAnimating)
    {
        UITouch *touch = [[event touchesForView:self] anyObject];
        [self.graph touchedAt:[touch locationInView:self]];
        return;
    }
    
    if (self.readonly|| self.graph == nil)
    {
        return;
    }
    
    if([touches count]>1)
    {
        return;
    }
    
    UITouch* touch = [[event touchesForView:self] anyObject];
    
    [selectedTool endCreateShape:[touch locationInView:self] forGroup:self.graph];
    
    if (self.drawableDelegate && [self.drawableDelegate respondsToSelector:@selector(didRefresh:)])
    {
        [self.drawableDelegate didRefresh:self];
    }
    
    [self draw];
}

-(UIImage *) glToUIImage
{
    NSInteger myDataLength = backingWidth * backingHeight * 4;
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    
    [self draw];
    glBindFramebufferOES(GL_DRAW_FRAMEBUFFER_APPLE, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    glReadPixels(0, 0, backingWidth, backingHeight, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y < backingHeight; y++)
    {
        for(int x = 0; x < backingWidth * 4; x++)
        {
            buffer2[(backingHeight - 1 - y) * backingWidth * 4 + x] = buffer[y * 4 * backingWidth + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * backingWidth;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(backingWidth, backingHeight, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

-(void)captureToPhotoAlbum
{
    UIImage *image = [self glToUIImage];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void) playSound
{
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle]  pathForResource:@"your audio file name" ofType:@"wav"]];
    AVAudioPlayer *clock  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:nil];
    [clock play];
}


- (UIScreen *)targetScreen
{
    return _targetScreen;
}

- (void)setTargetScreen:(UIScreen *)screen
{
    if (_targetScreen != screen)
    {
        _targetScreen = screen;
        
        if (_animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
    }
}

- (void) updateModel
{
    //NSLog(@"Update and draw");
    [self.graph animateStep];
    [self draw];
}

- (void)startAnimation
{
	if (!_animating)
	{
        [self.graph startAnimate];
        if (self.targetScreen) {
            // Create a CADisplayLink for the target display.
            // This will result in the native fps for whatever display you create it from.
            _displayLink = [self.targetScreen displayLinkWithTarget:self selector:@selector(updateModel)];
        }
        else {
            // Fall back to use CADislayLink's class method.
            // A CADisplayLink created using the class method is always bound to the internal display.
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateModel)];
        }
        [_displayLink setFrameInterval:self.animationFrameInterval];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        // An external display might just have been connected/disconnected. We do not want to
        // consider time spent in the connection/disconnection in the animation.
        _zeroDeltaTime = TRUE;
		_animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (_animating)
	{
        [self.graph endAnimate];
        [_displayLink invalidate];
        _displayLink = nil;
		_animating = FALSE;
	}
}

@end
