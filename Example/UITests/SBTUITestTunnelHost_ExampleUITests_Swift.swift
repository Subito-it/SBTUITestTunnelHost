// Copyright (C) 2023 Subito.it
//
// Licensed under the Apache License, Version 2.0 (the "License");

import SBTUITestTunnelHost
import XCTest

class SBTUITestTunnelHost_ExampleUITests_Swift: XCTestCase {
    func testHost() {
        // echo a string to a file and check that it is read correctly
        let app = XCUIApplication()
        app.launch()

        host.connect()

        let now = NSDate().timeIntervalSince1970

        let echoCmd = String(format: "echo %.2f > /tmp/tunnel-test", now)
        let echoCmdResult = host.executeCommand(echoCmd)

        let catUrl = URL(string: "http://127.0.0.1:8667/catfile?content-type=application/json&path=/tmp/tunnel-test")!
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
    
    func testExecuteCommandWithAmpersand() throws {
        let app = XCUIApplication()
        app.launch()

        host.connect()

        let cmd = "xcrun simctl openurl \(try deviceIdentifier()) 'https://www.google.com/search?q=tunnel&p=1'"
        _ = host.executeCommand(cmd)

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")

        wait { safari.state == .runningForeground }
    }
    
    func testLaunchCommandAndTerminate() throws {
        let app = XCUIApplication()
        app.launch()

        host.connect()

        let id = host.launchCommand("sleep 100")
        let status = host.getStatusOfCommand(with: id)
        
        let pid = try XCTUnwrap(status["pid"] as? Int)
        let ps = try XCTUnwrap(host.executeCommand("ps -p \(pid)"))
        XCTAssert(ps.contains("sleep 100"))
        
        host.terminateCommand(with: id)
                
        let psAfterTerminate = try XCTUnwrap(host.executeCommand("ps -p \(pid)"))
        XCTAssertFalse(psAfterTerminate.contains("sleep 100"))
    }
    
    func testLaunchCommandAndInterrupt() throws {
        let app = XCUIApplication()
        app.launch()

        host.connect()

        let id = host.launchCommand("sleep 100")
        let status = host.getStatusOfCommand(with: id)
        
        let pid = try XCTUnwrap(status["pid"] as? Int)
        let ps = try XCTUnwrap(host.executeCommand("ps -p \(pid)"))
        XCTAssert(ps.contains("sleep 100"))
        
        host.interruptCommand(with: id)
        
        let psAfterInterrupt = try XCTUnwrap(host.executeCommand("ps -p \(pid)"))
        XCTAssertFalse(psAfterInterrupt.contains("sleep 100"))
    }
    
    func testLaunchCommandAndWaitForCompletion() throws {
        let app = XCUIApplication()
        app.launch()

        host.connect()

        let id = host.launchCommand("date +%s000")
        Thread.sleep(forTimeInterval: 0.1)
        let status = host.getStatusOfCommand(with: id)
        
        let currentDate = Int(Date().timeIntervalSince1970)
        XCTAssert(try XCTUnwrap(status["stdOut"] as? String).contains("\(currentDate)"))
        
        XCTAssertEqual(try XCTUnwrap(status["stdErr"] as? String), "")
        XCTAssertEqual(try XCTUnwrap(status["terminationStatus"] as? Int), 0)
    }

    private func deviceIdentifier() throws -> String {
        let bundlePathComponents = Bundle.main.bundleURL.pathComponents
        guard let devicesIndex = bundlePathComponents.firstIndex(where: { $0 == "Devices" || $0 == "XCTestDevices" }),
              let deviceIdentifier = bundlePathComponents.dropFirst(devicesIndex + 1).first
        else {
            throw "Failed extracting device identifier"
        }

        return deviceIdentifier
    }
}

extension String: Error {}
