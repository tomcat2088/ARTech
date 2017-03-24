//
// Created by wangyang on 2017/3/15.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AR/video.h>

struct _ARNFTDataGenParam {
    int trackingExtractionLevel;
    int initExtractionLevel;
    float sdThresh;
    float maxThresh;
    float minThresh;
    BOOL genFSet;
    BOOL genFSet3;
};
typedef struct _ARNFTDataGenParam ARNFTDataGenParam;

@interface ARNFTDataCreator : NSObject
+ (void)genNFTDataWithImage:(UIImage *)image;
+ (void)genNFTData:(NSString *)imagePath;
+ (void)genNFTDataWithARBuffer:(AR2VideoBufferT *)buff size:(CGSize)imageSize channel:(int)channel;
@end
