//  SBTUITestTunnelHost_ExampleUITests_Swift.swift
//  SBTUITestTunnelHost_ExampleUITests
//
//  Created by Tomas Camin on 02/05/2017.
//  Copyright © 2017 tcamin. All rights reserved.
//

import XCTest
import SBTUITestTunnelHost

class SBTUITestTunnelHost_ExampleUITests_Swift: XCTestCase {

    func testExample() {
        // echo a string to a file and check that it is read correctly
        let app = XCUIApplication()
        app.launch()
        
        host.connect()
        
        let now = NSDate().timeIntervalSince1970
        
        let echoCmd = String(format: "echo %.2f > /tmp/tunnel-test", now)
        let echoCmdResult = host.executeCommand(echoCmd)
        
        let catUrl = URL(string: "http://127.0.0.1:8667/catfile?token=lkju32yt$%C2%A3bmnA&content-type=application/json&path=/tmp/tunnel-test")!
        let catResult = try! String(contentsOf: catUrl)
        let expectedCatResult = String(format: "%.2f\n", now)
        
        XCTAssertEqual(catResult, expectedCatResult)
        XCTAssertEqual(echoCmdResult, "")
    }
}
