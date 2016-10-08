//
//  UIImage+GL.m
//  OpenESRD
//
//  Created by wangyang on 2016/9/30.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import "UIImage+GL.h"

@implementation UIImage (GL)

+ (GLubyte *)dataFromImage:(NSString *)imageName width:(GLsizei *)pWidth height:(GLsizei *)pHeight {
    UIImage *img = [UIImage imageNamed:imageName];
    CGImageRef imageRef = [img CGImage];
    *pWidth = CGImageGetWidth(imageRef);
    *pHeight = CGImageGetHeight(imageRef);
    
    size_t width = *pWidth;
    size_t height = *pHeight;
    
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    return textureData;
}

@end
