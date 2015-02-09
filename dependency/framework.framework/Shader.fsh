//
//  Shader.fsh
//  GLDrawing
//
//  Created by Anping Wang on 10/19/14.
//  Copyright (c) 2014 SixStream. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
