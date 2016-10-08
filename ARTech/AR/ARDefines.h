//
//  ARDefines.h
//  ARToolKit5iOS
//
//  Created by wang yang on 2016/9/27.
//
//

#ifndef ARDefines_h
#define ARDefines_h

// Notifications.
extern NSString *const ARViewUpdatedCameraLensNotification;
extern NSString *const ARViewUpdatedCameraPoseNotification;
extern NSString *const ARViewUpdatedViewportNotification;

enum viewPortIndices {
    viewPortIndexLeft = 0,
    viewPortIndexBottom,
    viewPortIndexWidth,
    viewPortIndexHeight
};

typedef enum {
    ARViewContentScaleModeStretch = 0,
    ARViewContentScaleModeFit,
    ARViewContentScaleModeFill,
    ARViewContentScaleModeFit1to1
} ARViewContentScaleMode;

typedef enum {
    ARViewContentAlignModeTopLeft = 0,
    ARViewContentAlignModeTop,
    ARViewContentAlignModeTopRight,
    ARViewContentAlignModeLeft,
    ARViewContentAlignModeCenter,
    ARViewContentAlignModeRight,
    ARViewContentAlignModeBottomLeft,
    ARViewContentAlignModeBottom,
    ARViewContentAlignModeBottomRight,
} ARViewContentAlignMode;

#endif /* ARDefines_h */
