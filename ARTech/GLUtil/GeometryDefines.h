//
//  GeometryDefines.h
//  OpenESRD
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#ifndef GeometryDefines_h
#define GeometryDefines_h

enum {
    UNIFORM_VIEWPROJECTION,
    UNIFORM_MODEL_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#endif /* GeometryDefines_h */
