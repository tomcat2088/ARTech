//
//  NFTSetGenTests.m
//  ARTech
//
//  Created by wangyang on 2017/3/22.
//  Copyright © 2017年 wangyang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ARNFTDataCreator.h"

@interface NFTSetGenTests : XCTestCase

@end

@implementation NFTSetGenTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGen {
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"nft" ofType:@".jpeg" inDirectory:@"Markers"];
    [ARNFTDataCreator genNFTData:imgPath];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
@end
