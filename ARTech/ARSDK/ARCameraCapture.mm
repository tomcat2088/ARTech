//
// Created by wangyang on 2017/3/13.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import "ARCameraCapture.h"
#import "CameraVideo.h"
#import "param.h"


static void captureStartCallback(void *userdata);

@interface ARCameraCapture () <CameraVideoTookPictureDelegate> {

    NSTimeInterval  runLoopTimePrevious;
    BOOL isReady;
    CameraVideo *cameraVideo;
}
@property (copy, nonatomic) ARCameraCaptureOpenDeviceHandler openDeviceHandler;
@end

@implementation ARCameraCapture
@synthesize pixelFormat;

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)openDevice:(ARCameraCaptureOpenDeviceHandler)handler {
    self.openDeviceHandler = handler;
    // See http://www.artoolworks.com/support/library/Configuring_video_capture_in_ARToolKit_Professional#AR_VIDEO_DEVICE_IPHONE
    // -format=BGRA
    char *vconf = "-device=iPhone -preset=480p";
    if (!(self.videoID = ar2VideoOpenAsync(vconf, captureStartCallback, (__bridge void *)(self)))) {
        NSLog(@"Error: Unable to open connection to camera.\n");
        [self endCapture];
        self.openDeviceHandler(false);
        return;
    }
}

- (void)beginCapture {
    if (ar2VideoCapStart(self.videoID) != 0) {
        NSLog(@"Error: Unable to begin camera data capture.\n");
        [self endCapture];
        return;
    }
}

- (void)endCapture {
    if (ar2VideoCapStop(self.videoID) != 0) {
        NSLog(@"Error: Unable to stop camera data capture.\n");
    }
}

- (void)cameraVideoTookPicture:(id)sender userData:(void *)data {
    AR2VideoBufferT *buffer = ar2VideoGetImage(self.videoID);
    if (buffer) {
        [self.delegate arCameraCaptureDidCaptureData:buffer];
    }
}

#pragma mark - Private Methods
static void captureStartCallback(void *userdata) {
    ARCameraCapture *capture = (__bridge ARCameraCapture *)userdata;

    int xsize, ysize;
    if (ar2VideoGetSize(capture.videoID, &xsize, &ysize) < 0) {
        NSLog(@"Error: ar2VideoGetSize.\n");
        [capture endCapture];
        return;
    }

    AR_PIXEL_FORMAT pixelFormat = ar2VideoGetPixelFormat(capture.videoID);
    capture->pixelFormat = pixelFormat;
    if (pixelFormat == AR_PIXEL_FORMAT_INVALID) {
        NSLog(@"Error: Cameraself. is using unsupported pixel format.\n");
        [capture endCapture];
        return;
    }

    // Work out if the front camera is being used. If it is, flip the viewing frustum for
    // 3D drawing.
    BOOL flipV = FALSE;
    int frontCamera;
    if (ar2VideoGetParami(capture.videoID, AR_VIDEO_PARAM_IOS_CAMERA_POSITION, &frontCamera) >= 0) {
        if (frontCamera == AR_VIDEO_IOS_CAMERA_POSITION_FRONT) flipV = TRUE;
    }
    capture.isFlip = flipV;

    // Tell arVideo what the typical focal distance will be. Note that this does NOT
    // change the actual focus, but on devices with non-fixed focus, it lets arVideo
    // choose a better set of camera parameters.
    ar2VideoSetParami(capture.videoID, AR_VIDEO_PARAM_IOS_FOCUS, AR_VIDEO_IOS_FOCUS_1_0M); // Default is 0.3 metres. See <AR/sys/videoiPhone.h> for allowable values.

    // Load the camera parameters, resize for the window and init.
    ARParam cparam;
    if (ar2VideoGetCParam(capture.videoID, &cparam) < 0) {
        char cparam_name[] = "Data2/camera_para.dat";
        NSLog(@"Unable to automatically determine camera parameters. Using default.\n");
        if (arParamLoad(cparam_name, 1, &cparam) < 0) {
            NSLog(@"Error: Unable to load parameter file %s for camera.\n", cparam_name);
            [capture endCapture];
            return;
        }
    }

    if (cparam.xsize != xsize || cparam.ysize != ysize) {
#ifdef DEBUG
        fprintf(stdout, "*** Camera Parameter resized from %d, %d. ***\n", cparam.xsize, cparam.ysize);
#endif
        arParamChangeSize(&cparam, xsize, ysize, &cparam);
    }
#ifdef DEBUG
    fprintf(stdout, "*** Camera Parameter ***\n");
    arParamDisp(&cparam);
#endif

    if ((capture.arParamLT = arParamLTCreate(&cparam, AR_PARAM_LT_DEFAULT_OFFSET)) == NULL) {
        NSLog(@"Error: arParamLTCreate.\n");
        [capture endCapture];
        return;
    }

    capture->cameraVideo = ar2VideoGetNativeVideoInstanceiPhone(capture.videoID->device.iPhone);
    if (!capture->cameraVideo) {
        NSLog(@"Error: Unable to set up AR camera: missing CameraVideo instance.\n");
        [capture endCapture];
        return;
    }

    [capture->cameraVideo setTookPictureDelegate:capture];
    [capture->cameraVideo setTookPictureDelegateUserData:NULL];

    capture->isReady = YES;

    if (capture.openDeviceHandler) {
        capture.openDeviceHandler(YES);
    }
}
@end
