//
//  SSGLKView.m
//  SixStreams
//
//  Created by Anping Wang on 11/15/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

#import "SSGLKView.h"



#define kBrushOpacity		(1.0 / 3.0)
#define kBrushPixelStep		3
#define kBrushScale			2

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];

@interface SSGLKView () {
    GLuint _program;
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}
@end;

@implementation SSGLKView


- (void) drawRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);//background color
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.effect prepareToDraw];
    [self draw];
}


- (void) drawLine: (NSArray *) lines
{
    GLint points = 4;//(GLint)[lines count];
    GLfloat line[] =
    {
        0.0f, 0.0f, //point A
        1.0f, 0.0f, //point B
        1.0f, 1.0f, //point C
        0.0f, 1.0f, //point D
    };
    
    // Create a handle for a buffer object array
    
    GLuint bufferObjectNameArray;
    // Have OpenGL generate a buffer name and store it in the buffer object array
    glGenBuffers(1, &bufferObjectNameArray);
    // Bind the buffer object array to the GL_ARRAY_BUFFER target buffer
    glBindBuffer(GL_ARRAY_BUFFER, bufferObjectNameArray);
    // Send the line data over to the target buffer in GPU RAM
    glBufferData(
                 GL_ARRAY_BUFFER,   // the target buffer
                 sizeof(line),      // the number of bytes to put into the buffer
                 line,              // a pointer to the data being copied
                 GL_STATIC_DRAW);   // the usage pattern of the data
    
    // Enable vertex data to be fed down the graphics pipeline to be drawn
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // Specify how the GPU looks up the data
    glVertexAttribPointer(
                          GLKVertexAttribPosition, // the currently bound buffer holds the data
                          2,                       // number of coordinates per vertex
                          GL_FLOAT,                // the data type of each component
                          GL_FALSE,                // can the data be scaled
                          8,                       // how many bytes per vertex (2 floats per vertex)
                          NULL);                   // offset to the first coordinate, in this case 0
    
    glDrawArrays(GL_LINE_LOOP, 0, points); // render
}

- (void) drawGrid
{
    CGFloat start = 0;
    glLineWidth(0.1);
    
    if (self.gridHeight > 0)
    {
        for(int i= 0 ; start < 1; i++)
        {
            start = (i)*self.gridHeight;
            
            CGPoint startPt = CGPointMake(0, start);
            CGPoint toPt = CGPointMake(1, start);
            [self drawGridLine:startPt toPoint:toPt];
        }
    }
    if (self.gridWidth > 0)
    {
        start = 0;
        for(int i = 0; start < 1; i++)
        {
            start = (i)*self.gridWidth;
            CGPoint startPt = CGPointMake(start, 0.0);
            CGPoint toPt = CGPointMake(start, 1.0);
            [self drawGridLine:startPt toPoint:toPt];
        }
    }
}

- (void) draw
{
    if (self.graph)
    {
        if(self.showGrid)
        {
            [self drawGrid];
        }
       // [self.graph draw];
    }
}


- (void)drawGridLine:(CGPoint)start toPoint:(CGPoint)end
{
    static GLfloat*		vertexBuffer = NULL;
  
    // Allocate vertex array buffer
    if(vertexBuffer == NULL)
    {
        vertexBuffer = malloc(4 * sizeof(GLfloat));
    }
    
    vertexBuffer[0] = start.x ;
    vertexBuffer[1] = start.y;
    vertexBuffer[2] = end.x;
    vertexBuffer[3] = end.y;
    
    GLuint bufferObjectNameArray;
    // Have OpenGL generate a buffer name and store it in the buffer object array
    glGenBuffers(1, &bufferObjectNameArray);
    // Bind the buffer object array to the GL_ARRAY_BUFFER target buffer
    glBindBuffer(GL_ARRAY_BUFFER, bufferObjectNameArray);
    
    // Send the line data over to the target buffer in GPU RAM
    glBufferData(
                 GL_ARRAY_BUFFER,           // the target buffer
                 sizeof(vertexBuffer),      // the number of bytes to put into the buffer
                 vertexBuffer,              // a pointer to the data being copied
                 GL_STATIC_DRAW);           // the usage pattern of the data
    
    // Enable vertex data to be fed down the graphics pipeline to be drawn
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // Specify how the GPU looks up the data
    glVertexAttribPointer(
                          GLKVertexAttribPosition, // the currently bound buffer holds the data
                          2,                       // number of coordinates per vertex
                          GL_FLOAT,                // the data type of each component
                          GL_FALSE,                // can the data be scaled
                          8,                       // how many bytes per vertex (2 floats per vertex)
                          NULL);                   // offset to the first coordinate, in this case 0
    
    glDrawArrays(GL_LINE_LOOP, 0, 4); // render

}

- (void)setupGL
{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!context) {
        NSLog(@"Failed to create ES context");
    }
    self.gridHeight = 0.2;
    self.gridWidth = 0.2;
    self.showGrid = YES;
    self.context = context;
    [EAGLContext setCurrentContext:context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    // Let's color the line
    self.effect.useConstantColor = GL_TRUE;
    
    // Make the line a cyan color
    self.effect.constantColor = GLKVector4Make(
                                               1.0f, // Red
                                               1.0f, // Green
                                               0.0f, // Blue
                                               1.0f);// Alpha
}

- (void)tearDownGL
{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL) loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
