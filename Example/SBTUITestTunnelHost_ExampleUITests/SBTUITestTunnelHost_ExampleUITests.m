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
    
    NSURL *catURL = [NSURL URLWithString:@"http://127.0.0.1:8667/catfile?content-type=application/json&path=/tmp/tunnel-test"];
    NSString *catResult = [NSString stringWithContentsOfURL:catURL encoding:NSUTF8StringEncoding error:nil];
    NSString *expectedCatResult = [NSString stringWithFormat:@"%.2f\n", now];
    XCTAssert([catResult isEqualToString:expectedCatResult]);
    XCTAssert([echoCmdResult isEqualToString:@""]);
}

- (void)testMultipleTap {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    [self.host connect];
    
    XCUIElement *btn = app.buttons[@"Multiple tap test button"];
    
    SBTUITunneledHostMouseClick *mouseClick = [[SBTUITunneledHostMouseClick alloc] initWithElement:btn completionPause:0.05];

    [self.host executeMouseClicks:@[mouseClick, mouseClick, mouseClick] app:app];
    
    NSPredicate *existsPredicate = [NSPredicate predicateWithFormat:@"exists == true"];
    [self expectationForPredicate:existsPredicate evaluatedWithObject:app.alerts[@"Multi tap test"] handler:nil];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
    XCTAssert(app.alerts.staticTexts[@"3"].exists);
}

- (void)testMultipleDrag {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];
    
    [self.host connect];
    
    XCUIElement *table = app.tables.element;
    
    SBTUITunneledHostMouseDrag *mouseDrag = [[SBTUITunneledHostMouseDrag alloc] initWithElement:table
                                                                           startNormalizedPoint:CGPointMake(0.5, 0.9)
                                                                            stopNormalizedPoint:CGPointMake(0.5, 0.1)
                                                                                   dragDuration:0.1
                                                                                completionPause:0.05];
    
    [self.host executeMouseDrags:@[mouseDrag, mouseDrag, mouseDrag, mouseDrag, mouseDrag] app:app];
    
    [NSThread sleepForTimeInterval:2.0];
    
    XCTAssert(app.cells[@"99"].isHittable);
}

@end
