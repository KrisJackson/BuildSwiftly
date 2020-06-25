//
//  Verification_Test.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import XCTest
import Firebase
@testable import BuildSwiftly

class Verification_Test: XCTestCase {

    func testEmptyUser() {
        let user: User? = nil
        let expectation = XCTestExpectation(description: "Verification_Test.testEmptyUser")
            
        try! Auth.auth().signOut()
        Verification.sendTo(user: user) { (error) in
            
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.weak)
            try! Auth.auth().signOut()
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 10.0)
    }

}
