//
//  Geometry.h
//  OpenESRD
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

#import "GeometryDefines.h"
#import "GLProgram.h"

@interface GLGeometry : NSObject
@property (assign, nonatomic) GLuint vertexVBO;
@property (assign, nonatomic) GLuint indiceVBO;
@property (assign, nonatomic) GLuint vao;
@property (strong, nonatomic) GLProgram *glProgram;
@property (assign, nonatomic) GLKMatrix4 viewProjection;
@property (assign, nonatomic) GLKMatrix4 modelMatrix;
@property (assign, nonatomic) GLKMatrix3 normalMatrix;

- (instancetype)initWithWaveFrontFilePath:(NSString *)file;
- (void)draw;
- (void)update:(NSTimeInterval)interval;
@end
