//
//  ARGLRender.h
//  ARToolKit5iOS
//
//  Created by wang yang on 2016/9/27.
//
//

#import <Foundation/Foundation.h>

@interface ARGLRender : NSObject
// Drawing-related properties.
@property BOOL gDrawRotate;
- (void) drawCube:(float *)viewProjectionMatrix;
- (void) drawView:(id)sender;
- (void)setupWithProjection:(float *)viewProjection cameraPoseValid:(BOOL)cameraPoseValid;
- (void)updateWithTimeDelta:(NSTimeInterval)timeDelta;
@end
