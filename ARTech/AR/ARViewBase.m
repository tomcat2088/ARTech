//
//  ARViewBase.m
//  ARToolKit5iOS
//
//  Created by wang yang on 2016/9/27.
//
//

#import "ARViewBase.h"

@interface ARViewBase () {
    float cameraLens[16];
    float cameraPose[16];
    BOOL cameraPoseValid;

    float projection[16];
    GLint viewPort[4];
}
@end

@implementation ARViewBase

@synthesize contentWidth;
@synthesize contentHeight;
@synthesize contentRotate90;
@synthesize contentFlipH;
@synthesize contentFlipV;
@synthesize contentScaleMode;
@synthesize contentAlignMode;
@synthesize touchDelegate;

- (id) initWithFrame:(CGRect)frame pixelFormat:(NSString *)format depthFormat:(EAGLDepthFormat)depth withStencil:(BOOL)stencil preserveBackbuffer:(BOOL)retained {
    if ((self = [super initWithFrame:frame renderingAPI:kEAGLRenderingAPIOpenGLES2 pixelFormat:format depthFormat:depth withStencil:stencil preserveBackbuffer:retained])) {

        mtxLoadIdentityf(cameraLens);
        contentRotate90 = contentFlipH = contentFlipV = NO;
        mtxLoadIdentityf(projection);

        contentWidth = (int)frame.size.width;
        contentHeight = (int)frame.size.height;
        contentScaleMode = ARViewContentScaleModeFill;
        contentAlignMode = ARViewContentAlignModeCenter;

        cameraPoseValid = NO;

        // Init gestures.
        [self setMultipleTouchEnabled:YES];
        [self setTouchDelegate:self];

        // One-time OpenGL setup goes here.
        glStateCacheFlush();

        BOOL ok = CHECK_GL_ERROR();
    }

    return (self);

}

- (void)layoutSubviews {
    [super layoutSubviews];

    // Calculate viewport.
    int left, bottom, w, h;

#ifdef DEBUG
    NSLog(@"[ARView layoutSubviews] backingWidth=%d, backingHeight=%d\n", self.backingWidth, self.backingHeight);
#endif

    if (self.contentScaleMode == ARViewContentScaleModeStretch) {
        w = self.backingWidth;
        h = self.backingHeight;
    } else {
        int contentWidthFinalOrientation = (contentRotate90 ? contentHeight : contentWidth);
        int contentHeightFinalOrientation = (contentRotate90 ? contentWidth : contentHeight);
        if (self.contentScaleMode == ARViewContentScaleModeFit || self.contentScaleMode == ARViewContentScaleModeFill) {
            float scaleRatioWidth, scaleRatioHeight, scaleRatio;
            scaleRatioWidth = (float)self.backingWidth / (float)contentWidthFinalOrientation;
            scaleRatioHeight = (float)self.backingHeight / (float)contentHeightFinalOrientation;
            if (self.contentScaleMode == ARViewContentScaleModeFill) {
                scaleRatio = MAX(scaleRatioHeight, scaleRatioWidth);
            } else {
                scaleRatio = MIN(scaleRatioHeight, scaleRatioWidth);
            }
            w = (int)((float)contentWidthFinalOrientation * scaleRatio);
            h = (int)((float)contentHeightFinalOrientation * scaleRatio);
        } else {
            w = contentWidthFinalOrientation;
            h = contentHeightFinalOrientation;
        }
    }

    if (self.contentAlignMode == ARViewContentAlignModeTopLeft
        || self.contentAlignMode == ARViewContentAlignModeLeft
        || self.contentAlignMode == ARViewContentAlignModeBottomLeft) {
        left = 0;
    } else if (self.contentAlignMode == ARViewContentAlignModeTopRight
               || self.contentAlignMode == ARViewContentAlignModeRight
               || self.contentAlignMode == ARViewContentAlignModeBottomRight) {
        left = self.backingWidth - w;
    } else {
        left = (self.backingWidth - w) / 2;
    }

    if (self.contentAlignMode == ARViewContentAlignModeBottomLeft
        || self.contentAlignMode == ARViewContentAlignModeBottom
        || self.contentAlignMode == ARViewContentAlignModeBottomRight) {
        bottom = 0;
    } else if (self.contentAlignMode == ARViewContentAlignModeTopLeft
               || self.contentAlignMode == ARViewContentAlignModeTop
               || self.contentAlignMode == ARViewContentAlignModeTopRight) {
        bottom = self.backingHeight - h;
    } else {
        bottom = (self.backingHeight - h) / 2;
    }

    glViewport(left, bottom, w, h);

    viewPort[viewPortIndexLeft] = left;
    viewPort[viewPortIndexBottom] = bottom;
    viewPort[viewPortIndexWidth] = w;
    viewPort[viewPortIndexHeight] = h;
    [[NSNotificationCenter defaultCenter] postNotificationName:ARViewUpdatedViewportNotification object:self];
#ifdef DEBUG
    NSLog(@"[ARView layoutSubviews] viewport left=%d, bottom=%d, width=%d, height=%d\n", left, bottom, w, h);
#endif
}

- (float *)projection {
    return (projection);
}

- (GLint *)viewPort {
    return (viewPort);
}

- (void)setCameraLens:(float *)lens {
    if (lens) {
        mtxLoadMatrixf(cameraLens, lens);
        [self calculateProjection];
    }
}

- (float *)cameraLens {
    return (projection);
}

- (void) setContentRotate90:(BOOL)contentRotate90_in {
    contentRotate90 = contentRotate90_in;
    [self calculateProjection];
}

- (BOOL) contentRotate90 {
    return (contentRotate90);
}

- (void) setContentFlipH:(BOOL)contentFlipH_in {
    contentFlipH = contentFlipH_in;
    [self calculateProjection];
}

- (BOOL) contentFlipH {
    return (contentFlipH);
}

- (void) setContentFlipV:(BOOL)contentFlipV_in {
    contentFlipV = contentFlipV_in;
    [self calculateProjection];
}

- (BOOL) contentFlipV {
    return (contentFlipV);
}

- (void) calculateProjection {
    float const ir90[16] = { 0.0f, -1.0f, 0.0f, 0.0f,  1.0f, 0.0f, 0.0f, 0.0f,  0.0f, 0.0f, 1.0f, 0.0f,  0.0f, 0.0f, 0.0f, 1.0f };

    if (contentRotate90) {
        mtxLoadMatrixf(projection, ir90);
    } else {
        mtxLoadIdentityf(projection);
    }
    if (contentFlipH || contentFlipV) {
        mtxScalef(projection, (contentFlipH ? -1.0f : 1.0f), (contentFlipV ? -1.0f : 1.0f), 1.0f);
    }
    mtxMultMatrixf(projection, cameraLens);

    [[NSNotificationCenter defaultCenter] postNotificationName:ARViewUpdatedCameraLensNotification object:self];
}

- (void)setCameraPose:(float *)pose {
    if (pose) {
        int i;
        for (i = 0; i < 16; i++) {
            cameraPose[i] = pose[i];
        }
        cameraPoseValid = TRUE;
        [[NSNotificationCenter defaultCenter] postNotificationName:ARViewUpdatedCameraPoseNotification object:self];
    } else {
        cameraPoseValid = FALSE;
    }
}

- (float *)cameraPose {
    if (cameraPoseValid) {
        return (cameraPose);
    } else {
        return (NULL);
    }
}

- (BOOL)cameraPoseValid {
    return cameraPoseValid;
}

@end
