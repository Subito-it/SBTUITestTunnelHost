//
//  XCTestCase+Wait.swift
//  SBTUITestTunnelHost_ExampleUITests
//
//  Created by tomas.camin on 21/06/22.
//  Copyright © 2022 tcamin. All rights reserved.
//

import XCTest

extension XCTestCase {
    func wait(withTimeout timeout: TimeInterval = 30, assertOnFailure: Bool = true, _ message: @autoclosure () -> String = "", for predicateBlock: @escaping () -> Bool, file: StaticString = #filePath, line: UInt = #line) {
        let predicate = NSPredicate { _, _ in predicateBlock() }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        
        if assertOnFailure {
            XCTAssert(result == .completed, message(), file: file, line: line)
        }
    }
}

