//
//  ARBaseViewController.h
//  ARTech
//
//  Created by wangyang on 2017/3/21.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "EZGLBaseViewController.h"
#import "ARMarkerDetector.h"

@class ARCameraCapture;


@interface ARBaseViewController : EZGLBaseViewController
@property  (strong, nonatomic) ARCameraCapture *cameraCapture;
@property  (assign, nonatomic) EL2DPlane *videoPlane;

- (id<ARMarkerDetector>)preferMarkerDetector;
- (void)arDidBeganDetect;
- (void)arWillProcessFrame:(AR2VideoBufferT *)buffer;
- (void)arDetecting:(NSArray *)poses;
- (void)arDidPauseDetect;
- (void)arDidResumeDetect;
- (void)arDidEndDetect;
@end
