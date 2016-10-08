//
//  GLWorld.h
//  OpenESRD
//
//  Created by wang yang on 2016/10/7.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

@class Geometry;

@interface GLWorld : NSObject

@property (strong, nonatomic) EAGLContext *context;
@property (assign, nonatomic) GLKMatrix4 viewProjection;

- (instancetype)initWithGLKView:(GLKView *)glkView;
- (void)addGeometry:(Geometry *)geometry;
- (void)render;
- (void)update:(NSTimeInterval)interval;
@end
