//
//  ARSquareMarkerDetector.h
//  ARTech
//
//  Created by wangyang on 2017/3/13.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AR/ar.h>
#include <AR/video.h>
#import "ARMarkerDetector.h"

@interface ARSquareMarkerDetector : NSObject <ARMarkerDetector>
- (CGSize)size;
- (BOOL)detect:(AR2VideoBufferT *)buffer modelMatrix:(float *)modelMatrix;
- (bool)setupWith:(ARParamLT *)paramLT pixelFormat:(AR_PIXEL_FORMAT)pixelFormat;
@end
