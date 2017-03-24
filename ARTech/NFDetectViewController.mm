//
//  NFDetectViewController.m
//  ARTech
//
//  Created by wangyang on 2017/3/16.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "NFDetectViewController.h"
#import "ARNaturalFeatureDetector.h"
#import "ARCameraCapture.h"
#import "ARNFTDataCreator.h"

@interface NFDetectViewController () {
    uint8_t *detectingPlane;
    uint8_t *waitingPlane;
    cv::KeyPoint first;
    BOOL ptValid;
    ELGameObject *nfPlane;
    ELTexture *featureDetectTexture;
    BOOL needCapture;
}

@property (strong, nonatomic) ARNaturalFeatureDetector *nfDetector;
@property (strong, nonatomic) dispatch_queue_t detectQueue;
@property (strong, nonatomic) dispatch_semaphore_t semaphore;
@end

@implementation NFDetectViewController
ELGameObject * createVideoPlane3(ELWorld *world, ELVector2 size, GLuint diffuseMap, GLuint normalMap) {
    ELGameObject *gameObject = new ELGameObject(world);
    world->addNode(gameObject);
    EL2DPlane *plane = new EL2DPlane(size);
    gameObject->addComponent(plane);
    plane->materials[0].diffuseMap = diffuseMap;
    plane->materials[0].normalMap = normalMap;
    return gameObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nfDetector = [ARNaturalFeatureDetector new];
    ptValid = NO;
    needCapture = NO;
    featureDetectTexture = ELTexture::texture(ELAssets::shared()->findFile("particle_point.png"));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        needCapture = YES;
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)arWillProcessFrame:(AR2VideoBufferT *)buffer {
    if (needCapture) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [ARNFTDataCreator genNFTDataWithImage:image];
        needCapture = NO;
    }
//    static std::vector<cv::KeyPoint> kpts;
//    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//    [self copyBuf:buffer->bufPlanes[0] to:waitingPlane size:self.cameraCapture.arParamLT->paramLTf.xsize * self.cameraCapture.arParamLT->paramLTf.ysize * sizeof(uint8_t)];
//    dispatch_semaphore_signal(self.semaphore);
    dispatch_async(self.detectQueue, ^{
//        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//        uint8_t *swapTemp = waitingPlane;
//        waitingPlane = detectingPlane;
//        detectingPlane = swapTemp;
//        dispatch_semaphore_signal(self.semaphore);
//        std::vector<cv::KeyPoint> keyPts = [self.nfDetector detectFeatures:detectingPlane size:CGSizeMake(self.cameraCapture.arParamLT->paramLTf.xsize, self.cameraCapture.arParamLT->paramLTf.ysize)];
//        if (keyPts.size() > 0) {
//            first = keyPts.at(keyPts.size() - 1);
//            ptValid = YES;
//        } else {
//            ptValid = NO;
//        }
//        kpts = keyPts;
    });
    
//    if(ptValid) {
//        cv::Mat imgMat = [self.nfDetector featuresImage:kpts];
//        featureDetectTexture->reset(imgMat.data, imgMat.cols, imgMat.rows, GL_RGBA);
//        self.videoPlane->materials[0].specularMap = featureDetectTexture->value;
//        //        if (nfPlane == nil) {
//        //            GLuint tex = ELTexture::texture(ELAssets::shared()->findFile("dirt.png"))->value;
//        //            nfPlane = createVideoPlane3([self world], ELVector2Make(10, 10), tex, tex);
//        //        }
//        //
//        //        nfPlane->transform->position = ELVector3Make(first.pt.x, first.pt.y, 0);
//    }

}

-(void)arDidBeganDetect {
    int bufSize = self.cameraCapture.arParamLT->param.xsize * self.cameraCapture.arParamLT->param.ysize;
    waitingPlane = (uint8_t *)malloc(bufSize);
    detectingPlane = (uint8_t *)malloc(bufSize);
}


- (dispatch_queue_t)detectQueue {
    if (_detectQueue == nil) {
        _detectQueue = dispatch_queue_create("queue.detectNF", 0);
    }
    return _detectQueue;
}

- (dispatch_semaphore_t)semaphore {
    if (_semaphore == nil) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return _semaphore;
}

- (void)copyBuf:(uint8_t *)fromBuf to:(uint8_t *)toBuf size:(int)size {
    memcpy(toBuf, fromBuf, size);
}

@end
