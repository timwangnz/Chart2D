//
//  GLView.m
//  Anping Wang
//
//  Created by Anping Wang on 11/1/12.
//  Copyright (c) 2012 s. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>

#import <Parse/Parse.h>

#import "SSDrawableLayer.h"
#import "GLPen.h"
#import "SSLinePoint.h"
#import "SSLine.h"
#import "SSShape.h"
#import "SSConnection.h"
#import "SixStreams.h"
#import "SSProfileVC.h"
#import "SSGraph.h"

#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"


#define kBrushOpacity		(1.0 / 3.0)
#define kBrushPixelStep		3
#define kBrushScale			2

// Shaders
enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
    UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBS
};

typedef struct {
    char *vert, *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },     // PROGRAM_POINT
};

typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;


@interface SSDrawableLayer()
{
	GLint   backingWidth;
	GLint   backingHeight;
    
    //GLuint	brushTexture;
	EAGLContext *context;
    
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer, depthRenderbuffer;
    
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint msaaFramebuffer, msaaRenderBuffer, msaaDepthBuffer;
    GLuint vboId;
    textureInfo_t brushTexture;     // brush texture
    GLfloat brushColor[4];          // brush color

    
    UIImage *backgroundImg;
   
    BOOL inReplay;
    
    SSTool *selectedTool;
    BOOL clearBufferRequired;
    //
    UIScreen *_targetScreen;
    CADisplayLink *_displayLink;
    BOOL _zeroDeltaTime;
    NSInteger _animationFrameInterval;
    BOOL initialized;
    BOOL needsErase;
}
@end


@implementation SSDrawableLayer

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setGL {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return;
        }
        
        // Set the view's scale factor as you wish
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        // Make sure to start with a cleared buffer
        needsErase = YES;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
    // Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    // For this sample, we do not need a depth buffer. If you do, this is how you can allocate depth buffer backing:
    //    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    //    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    // Update projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    
    // Update viewport
    glViewport(0, 0, backingWidth, backingHeight);
    
    return YES;
}

-(void)layoutSubviews
{
    [EAGLContext setCurrentContext:context];
    
    if (!initialized) {
        initialized = [self initGL];
    }
    else {
        [self resizeFromLayer:(CAEAGLLayer*)self.layer];
    }
    
    // Clear the framebuffer the first time it is allocated
    if (needsErase) {
        [self eraseBuffer];
        needsErase = NO;
    }
}

- (void)eraseBuffer
{
    [EAGLContext setCurrentContext:context];
    
    // Clear the buffer
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)setBrushColorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    // Update the brush color
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
    if (initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
}

- (BOOL)initGL
{
    // Generate IDs for a framebuffer object and a color renderbuffer
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    // This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
    // allowing us to draw into a buffer that will later be rendered to screen wherever the layer is (which corresponds with our view).
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    // For this sample, we do not need a depth buffer. If you do, this is how you can create one and attach it to the framebuffer:
    //    glGenRenderbuffers(1, &depthRenderbuffer);
    //    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    //    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
    //    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    // Setup the view port in Pixels
    glViewport(0, 0, backingWidth, backingHeight);
    
    // Create a Vertex Buffer Object to hold our data
    glGenBuffers(1, &vboId);
    
    // Load the brush texture
    brushTexture = [self textureFromName:@"Particle.png"];
    
    // Load shaders
    [self setupShaders];
    
    // Enable blending and set a blending function appropriate for premultiplied alpha pixel data
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    return YES;
}

- (void)setupShaders
{
    for (int i = 0; i < NUM_PROGRAMS; i++)
    {
        char *vsrc = readFile(pathForResource(program[i].vert));
        char *fsrc = readFile(pathForResource(program[i].frag));
        GLsizei attribCt = 0;
        GLchar *attribUsed[NUM_ATTRIBS];
        GLint attrib[NUM_ATTRIBS];
        GLchar *attribName[NUM_ATTRIBS] = {
            "inVertex",
        };
        const GLchar *uniformName[NUM_UNIFORMS] = {
            "MVP", "pointSize", "vertexColor", "texture",
        };
        
        // auto-assign known attribs
        for (int j = 0; j < NUM_ATTRIBS; j++)
        {
            if (strstr(vsrc, attribName[j]))
            {
                attrib[attribCt] = j;
                attribUsed[attribCt++] = attribName[j];
            }
        }
        
        glueCreateProgram(vsrc, fsrc,
                          attribCt, (const GLchar **)&attribUsed[0], attrib,
                          NUM_UNIFORMS, &uniformName[0], program[i].uniform,
                          &program[i].id);
        free(vsrc);
        free(fsrc);
        
        // Set constant/initalize uniforms
        if (i == PROGRAM_POINT)
        {
            glUseProgram(program[PROGRAM_POINT].id);
            
            // the brush texture will be bound to texture unit 0
            glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);
            
            // viewing matrices
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity; // this sample uses a constant identity modelView matrix
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            
            glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
            
            // point size
            glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushTexture.width / kBrushScale);
            
            // initialize brush color
            glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
        }
    }
    
    glError();
}


// Create a texture from an image
- (textureInfo_t)textureFromName:(NSString *)name
{
    CGImageRef		brushImage;
    CGContextRef	brushContext;
    GLubyte			*brushData;
    size_t			width, height;
    GLuint          texId;
    textureInfo_t   texture;
    
    // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = [UIImage imageNamed:name].CGImage;
    
    // Get the width and height of the image
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
    // Make sure the image exists
    if(brushImage) {
        // Allocate  memory needed for the bitmap context
        brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        // Use  the bitmatp creation function provided by the Core Graphics framework.
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &texId);
        // Bind the texture name.
        glBindTexture(GL_TEXTURE_2D, texId);
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        // Release  the image data; it's no longer needed
        free(brushData);
        
        texture.id = texId;
        texture.width = (int)width;
        texture.height = (int)height;
    }
    
    return texture;
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
        self.gridWidth = 40;
        self.gridHeight = 40;
        [self setGL];
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

#pragma undo redo

- (BOOL) isUndoable
{
    return [self.graph isUndoable];
}

- (BOOL) isRedoable
{
    return [self.graph isUndoable];
}

- (void) redraw
{
    [self draw];
    
}

- (void) drawRect:(CGRect)rect
{
    [self draw];
}

- (void) draw
{
    if(self.showGrid)
    {
        [self drawGrid];
    }
    //[self.graph draw];
}


- (void)drawGridLine:(CGPoint)start toPoint:(CGPoint)end
{
    static GLfloat*		vertexBuffer = NULL;
    static NSUInteger	vertexMax = 64;
    GLsizei			vertexCount = 0,
    count,
    i;
    
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    // Convert locations from Points to Pixels
    CGFloat scale = self.contentScaleFactor;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    // Allocate vertex array buffer
    if(vertexBuffer == NULL)
        vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    
    // Add points to the buffer so there are drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            vertexBuffer = realloc(vertexBuffer, vertexMax * 2 * sizeof(GLfloat));
        }
        
        vertexBuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        vertexBuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
    }
    
    
    // Load data to the Vertex Buffer Object
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(GLfloat), vertexBuffer, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    // Draw
   // glUseProgram(program[PROGRAM_POINT].id);
    glDrawArrays(GL_POINTS, 0, (int)vertexCount);
    //glVertexPointer(2, GL_FLOAT, 0, vertexBuffer);
    //glDrawArrays(GL_LINE_LOOP, 0, (int)vertexCount);
    // Display the buffer
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void) drawGrid
{
    CGFloat start = 0;
    glLineWidth(0.1);
  
    if (self.gridHeight > 0)
    {
        for(int i= 0 ; start < self.bounds.size.height; i++)
        {
            start = (i)*self.gridHeight;
            
            CGPoint startPt = CGPointMake(0, start);
            CGPoint toPt = CGPointMake(self.bounds.size.width, start);
            [self drawGridLine:startPt toPoint:toPt];
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
            [self drawGridLine:startPt toPoint:toPt];
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
    
    if (self.drawableDelegate && [self.drawableDelegate respondsToSelector:@selector(viewDidRefresh:)])
    {
        [self.drawableDelegate viewDidRefresh:self];
    }
    
    [self draw];
}

-(UIImage *) glToUIImage
{
    NSInteger myDataLength = backingWidth * backingHeight * 4;
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    
    [self draw];
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
