//
//  ARViewBase.h
//  ARToolKit5iOS
//
//  Created by wang yang on 2016/9/27.
//
//

#import "EAGLView.h"
#import "ARViewTouchDelegate.h"
#import "ARDefines.h"
#include <AR/gsub_es2.h>
#include <AR/gsub_mtx.h>

@interface ARViewBase : EAGLView

// These properties allow variation on the way content is drawn in the GL window.
@property int contentWidth;
@property int contentHeight;
@property BOOL contentRotate90;
@property BOOL contentFlipH;
@property BOOL contentFlipV;
@property ARViewContentScaleMode contentScaleMode; // Defaults to ARViewContentScaleModeFill.
@property ARViewContentAlignMode contentAlignMode; // Defaults to ARViewContentAlignModeCenter.

@property float *projection;

@property float *cameraLens;
@property float *cameraPose;
@property (readonly) GLint *viewPort;
@property BOOL cameraPoseValid;
@property (nonatomic, assign) id <ARViewTouchDelegate> touchDelegate;

- (void) updateWithTimeDelta:(NSTimeInterval)timeDelta;
- (void) drawView:(id)sender;

@end
