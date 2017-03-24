//
// Created by wangyang on 2017/3/15.
// Copyright (c) 2017 wangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/core/core.hpp>
#import <opencv2/features2d/features2d.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/xfeatures2d/nonfree.hpp>

@interface ARNaturalFeatureDetector : NSObject
- (std::vector<cv::KeyPoint>)detectFeatures:(uint8_t *)imageData size:(CGSize)imgSize;
- (cv::Mat)featuresImage:(std::vector<cv::KeyPoint>)keypoints;
@end
