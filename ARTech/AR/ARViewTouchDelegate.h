//
//  ARTouchDelegate.h
//  ARToolKit5iOS
//
//  Created by wang yang on 2016/9/27.
//
//

#import <Foundation/Foundation.h>

@protocol ARViewTouchDelegate<NSObject>
@optional
- (void) handleTouchAtLocation:(CGPoint)location tapCount:(NSUInteger)tapCount;
@end
