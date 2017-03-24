//
//  ARMarkerPose.m
//  ARTech
//
//  Created by wangyang on 2017/3/21.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "ARMarkerPose.h"

@interface ARMarkerPose () {
    float _matrix[16];
}

@end

@implementation ARMarkerPose
- (id)initWithMatrix:(float [16])matrix {
    self = [super init];
    if (self) {
        for (int i = 0; i < 16; ++i) {
            _matrix[i] = matrix[i];
        }
    }
    return self;
}

- (float *)matrix {
    return _matrix;
}

@end
