//
//  UINavigationController+Appearance.m
//  ARTech
//
//  Created by wangyang on 2017/3/23.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import "UINavigationController+Appearance.h"

@implementation UINavigationController (Appearance)
+ (void)initialize
{
    UIColor *tintColor = [UIColor whiteColor];
    if (self == [UINavigationController class]) {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
        [[UINavigationBar appearance] setTintColor:tintColor];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: tintColor}];
    }
}
@end
