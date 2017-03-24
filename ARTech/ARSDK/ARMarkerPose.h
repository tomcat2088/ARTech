//
//  ARMarkerPose.h
//  ARTech
//
//  Created by wangyang on 2017/3/21.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARMarkerPose : NSObject
- (id)initWithMatrix:(float [16])matrix;
- (float *)matrix;
@end
