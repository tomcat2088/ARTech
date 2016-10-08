//
//  GLWorld.m
//  OpenESRD
//
//  Created by wang yang on 2016/10/7.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import "GLWorld.h"
#import "GLGeometry.h"

@interface GLWorld ()

@property (strong, nonatomic) NSMutableArray *geometrys;

@end

@implementation GLWorld

- (instancetype)initWithGLKView:(GLKView *)glkView {
    self = [super init];
    if (self) {
        CGSize size = glkView.bounds.size;

        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        if (!self.context) {
            NSLog(@"Failed to create ES context");
        }

        glkView.context = self.context;
        glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        [EAGLContext setCurrentContext:self.context];
        glEnable(GL_DEPTH_TEST);

        float aspect = fabs(size.width / size.height);
        self.viewProjection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

        self.geometrys = [NSMutableArray new];
    }
    return self;
}

- (void)addGeometry:(Geometry *)geometry {
    [self.geometrys addObject:geometry];
}

- (void)render {
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    for (GLGeometry *geometry in self.geometrys) {
        geometry.viewProjection = self.viewProjection;
        [geometry draw];
    }
}

- (void)update:(NSTimeInterval)interval {
    for (GLGeometry *geometry in self.geometrys) {
        [geometry update:interval];
    }
}

@end
