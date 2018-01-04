//  SBTUITestTunnelHost_ExampleUITests_Swift.swift
//  SBTUITestTunnelHost_ExampleUITests
//
//  Created by Tomas Camin on 02/05/2017.
//  Copyright © 2017 tcamin. All rights reserved.
//

import XCTest
import SBTUITestTunnelHost

class SBTUITestTunnelHost_ExampleUITests_Swift: XCTestCase {

    func testHost() {
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
    
    func testMultipleTap() {
        let app = XCUIApplication()
        app.launch()
        
        host.connect()
        
        let btn = app.buttons["Multiple tap test button"]
        
        let mouseClick = SBTUITunneledHostMouseClick(element: btn, completionPause: 0.05)
        
        let mouseCliks = Array(repeating: mouseClick, count: 3)
        host.execute(mouseCliks, app: app)
        
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: app.alerts["Multi tap test"], handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        XCTAssert(app.alerts.staticTexts["3"].exists)
    }
    
    func testMultipleDrag() {
        let app = XCUIApplication()
        app.launch()
        
        host.connect()
    
        let table = app.tables.element
    
        let mouseDrag = SBTUITunneledHostMouseDrag(element: table, startNormalizedPoint: CGPoint(x: 0.5, y: 0.9), stopNormalizedPoint: CGPoint(x: 0.5, y: 0.1), dragDuration: 0.1, completionPause: 0.05)
        
        let mouseDrags = Array(repeating: mouseDrag, count: 8)
        host.execute(mouseDrags, app: app)
    
        Thread.sleep(forTimeInterval: 2.0)
    
        XCTAssert(app.cells["99"].isHittable)
    }
}
