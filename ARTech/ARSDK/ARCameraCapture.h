//
// Created by wangyang on 2017/3/13.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AR/video.h>

typedef void (^ARCameraCaptureOpenDeviceHandler)(BOOL success);

@protocol ARCameraCaptureDelegate
- (void)arCameraCaptureDidCaptureData:(AR2VideoBufferT *)buffer;
@end

@interface ARCameraCapture : NSObject
@property (assign, nonatomic) ARParamLT *arParamLT;
@property (assign, nonatomic) BOOL isFlip;
@property (assign, nonatomic) AR_PIXEL_FORMAT pixelFormat;
@property (assign, nonatomic) AR2VideoParamT *videoID;

@property (weak, nonatomic) id<ARCameraCaptureDelegate> delegate;

- (void)openDevice:(ARCameraCaptureOpenDeviceHandler)openDeviceHandler;
- (void)beginCapture;
- (void)endCapture;
@end
