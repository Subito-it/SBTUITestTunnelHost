//
//  SBTUITestTunnelHost_ExampleUITests.m
//  SBTUITestTunnelHost_ExampleUITests
//
//  Created by Tomas Camin on 02/05/2017.
//  Copyright © 2017 tcamin. All rights reserved.
//

#import <XCTest/XCTest.h>
@import SBTUITestTunnelHost;

@interface SBTUITestTunnelHost_ExampleUITests : XCTestCase

@end

@implementation SBTUITestTunnelHost_ExampleUITests

- (void)testHost {
    // echo a string to a file and check that it is read correctly
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    [self.host connect];
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSString *echoCmd = [NSString stringWithFormat:@"echo %.2f > /tmp/tunnel-test", now];
    NSString *echoCmdResult = [self.host executeCommand:echoCmd];
    
    NSURL *catURL = [NSURL URLWithString:@"http://127.0.0.1:8667/catfile?token=lkju32yt$%C2%A3bmnA&content-type=application/json&path=/tmp/tunnel-test"];
    NSString *catResult = [NSString stringWithContentsOfURL:catURL encoding:NSUTF8StringEncoding error:nil];
    NSString *expectedCatResult = [NSString stringWithFormat:@"%.2f\n", now];
    XCTAssert([catResult isEqualToString:expectedCatResult]);
    XCTAssert([echoCmdResult isEqualToString:@""]);
}

@end
