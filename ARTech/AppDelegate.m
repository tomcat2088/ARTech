//
//  AppDelegate.m
//  ARTech
//
//  Created by wangyang on 2016/10/8.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ARNFTDataCreator.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController: [[HomeViewController alloc] initWithStyle:UITableViewStyleGrouped]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
