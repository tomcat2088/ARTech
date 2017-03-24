//
//  ARSquareMarkerDetector.m
//  ARTech
//
//  Created by wangyang on 2017/3/13.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "ARSquareMarkerDetector.h"
#import "video.h"
#import "ar.h"
#include "argl.h"

@interface ARSquareMarkerDetector () {

    ARHandle       *gARHandle;
    ARPattHandle   *gARPattHandle;
    long            gCallCountMarkerDetect;

    // Transformation matrix retrieval.
    AR3DHandle     *gAR3DHandle;
    ARdouble        gPatt_width;            // Per-marker, but we are using only 1 marker.
    ARdouble        gPatt_trans[3][4];      // Per-marker, but we are using only 1 marker.
    int             gPatt_found;            // Per-marker, but we are using only 1 marker.
    int             gPatt_id;               // Per-marker, but we are using only 1 marker.
    BOOL            useContPoseEstimation;
}
@end

@implementation ARSquareMarkerDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        gARHandle = NULL;
        gARPattHandle = NULL;
        gCallCountMarkerDetect = 0;
        gAR3DHandle = NULL;
        useContPoseEstimation = FALSE;
    }
    return self;
}

- (CGSize)size {
    return CGSizeMake(gARHandle->xsize, gARHandle->ysize);
}

- (bool)setupWith:(ARParamLT *)paramLT pixelFormat:(AR_PIXEL_FORMAT)pixelFormat {
    // AR init.
    if ((gARHandle = arCreateHandle(paramLT)) == NULL) {
        NSLog(@"Error: arCreateHandle.\n");
        return NO;
    }
    if (arSetPixelFormat(gARHandle, pixelFormat) < 0) {
        NSLog(@"Error: arSetPixelFormat.\n");
        return NO;
    }
    if ((gAR3DHandle = ar3DCreateHandle(&paramLT->param)) == NULL) {
        NSLog(@"Error: ar3DCreateHandle.\n");
        return NO;
    }
    arSetMarkerExtractionMode(gARHandle, AR_USE_TRACKING_HISTORY_V2);
    return [self setupPattern];
}

- (BOOL)setupPattern {
    // Prepare ARToolKit to load patterns.
    if (!(gARPattHandle = arPattCreateHandle())) {
        NSLog(@"Error: arPattCreateHandle.\n");
        return NO;
    }
    arPattAttach(gARHandle, gARPattHandle);

    // Load marker(s).
    // Loading only 1 pattern in this example.
    char *patt_name  = "Data2/hiro.patt";
    if ((gPatt_id = arPattLoad(gARPattHandle, patt_name)) < 0) {
        NSLog(@"Error loading pattern file %s.\n", patt_name);
        return NO;
    }

    gPatt_width = 40.0f;
    gPatt_found = FALSE;
    return YES;
}

- (BOOL)detect:(AR2VideoBufferT *)buffer modelMatrix:(float *)modelMatrix {
    if (arDetectMarker(gARHandle, buffer->buff) < 0) {
        return NO;
    }

    if (gARHandle->marker_num <= 0) {
        return NO;
    }

    // 选择自信度最高的结果
    int mostConfidentResult = -1;
    for (int i = 0; i < gARHandle->marker_num; ++i) {
        if (gARHandle->markerInfo[i].id == gPatt_id) {
            if (mostConfidentResult == -1) {
                mostConfidentResult = i;
            } else if (gARHandle->markerInfo[i].cf > gARHandle->markerInfo[mostConfidentResult].cf) {
                mostConfidentResult = i;
            }
        }
    }

    if (mostConfidentResult < 0) {
        return NO;
    }

    // 计算Marker相对于Camera的变换矩阵
    arGetTransMatSquare(gAR3DHandle, &(gARHandle->markerInfo[mostConfidentResult]), gPatt_width, gPatt_trans);
#ifdef ARDOUBLE_IS_FLOAT
    arglCameraViewRHf(gPatt_trans, modelMatrix, 1.0);
#else
    float patt_transf[3][4];
            int r, c;
            for (r = 0; r < 3; r++) {
                for (c = 0; c < 4; c++) {
                    patt_transf[r][c] = (float)(gPatt_trans[r][c]);
                }
            }
            arglCameraViewRHf(patt_transf, modelview, 1.0);
#endif


    return YES;
}

@end
