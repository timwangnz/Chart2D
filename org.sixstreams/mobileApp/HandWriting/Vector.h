//
//  Vector.h
//  Graph2DTestApp
//
//  Created by Anping Wang on 12/8/12.
//  Copyright (c) 2012 Anping Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;
} Vertex3D;

typedef struct {
    Vertex3D v1;
    Vertex3D v2;
    Vertex3D v3;
} Triangle3D;

static inline Vertex3D Vertex3DMake(CGFloat inX, CGFloat inY, CGFloat inZ)
{
    Vertex3D ret;
    ret.x = inX;
    ret.y = inY;
    ret.z = inZ;
    return ret;
}

static inline void Vertex3DSet(Vertex3D *vertex, CGFloat inX, CGFloat inY, CGFloat inZ)
{
    vertex->x = inX;
    vertex->y = inY;
    vertex->z = inZ;
}

static inline Triangle3D Triangle3DMake(Vertex3D inX, Vertex3D inY, Vertex3D inZ)
{
    Triangle3D ret;
    ret.v1 = inX;
    ret.v2 = inY;
    ret.v3 = inZ;
    return ret;
}

static inline GLfloat Vertex3DCalculateDistanceBetweenVertices (Vertex3D first, Vertex3D second)
{
    GLfloat deltaX = second.x - first.x;
    GLfloat deltaY = second.y - first.y;
    GLfloat deltaZ = second.z - first.z;
    return sqrtf(deltaX*deltaX + deltaY*deltaY + deltaZ*deltaZ );
};


@interface Vector : NSObject
@property(nonatomic, assign) float x;
@property(nonatomic, assign) float y;
@property(nonatomic, assign) CGPoint start;

-(CGFloat) getAngle;
-(CGFloat) getSimilarity:(Vector *) compareTo;

@end
