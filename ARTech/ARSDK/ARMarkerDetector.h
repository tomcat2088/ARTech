//
// Created by wangyang on 2017/3/15.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AR/ar.h>
#include <AR/video.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol ARMarkerDetector
- (CGSize)size;
- (BOOL)detect:(AR2VideoBufferT *)buffer modelMatrix:(float *)modelMatrix;
- (bool)setupWith:(ARParamLT *)paramLT pixelFormat:(AR_PIXEL_FORMAT)pixelFormat;
@end
