//
//  Login_Test.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import XCTest
import Firebase
@testable import BuildSwiftly

class Login_Test: XCTestCase {
    
    func testEmptyEmail() {
        let email = ""
        let password = "SomeRandomPassword"
        let expectation = XCTestExpectation(description: "Login_Test.testEmptyEmail")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertFalse(error.type == Error.ErrorType.none)
            XCTAssertTrue(error.type == Error.ErrorType.weak)
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 20.0)
    }

    func testEmptyPassword() {
        let email = "random@gmail.com"
        let password = ""
        let expectation = XCTestExpectation(description: "Login_Test.testEmptyPassword")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertFalse(error.type == Error.ErrorType.none)
            XCTAssertTrue(error.type == Error.ErrorType.weak)
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testEmailWithNoExtension() {
        let email = "badEmailFormat"
        let password = "SomeRandomPassword"
        let expectation = XCTestExpectation(description: "Login_Test.testEmailWithNoExtension")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.system)
            expectation.fulfill()

        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testEmailWithBadExtension() {
        let email = "badEmailFormat@"
        let password = "SomeRandomPassword"
        let expectation = XCTestExpectation(description: "Login_Test.testEmailWithBadExtension")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.system)
            expectation.fulfill()

        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testEmailWithNoDomainNameExtension() {
        // Does not throw bad format error
        // Treats like normal email address and throws error for no available record
        let email = "badEmail@format"
        let password = "SomeRandomPassword"
        let expectation = XCTestExpectation(description: "Login_Test.testEmailWithNoDomainNameExtension")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.system)
            expectation.fulfill()

        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testEmailWithSpace() {
        let email = "badEmail @gmail.com"
        let password = "SomeRandomPassword"
        let expectation = XCTestExpectation(description: "Login_Test.testEmailWithSpace")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.system)
            expectation.fulfill()

        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testLoginWithBadPassword() {
        let email = "test@gmail.com"
        let password = "FakePassword"
        let expectation = XCTestExpectation(description: "Login_Test.testLoginWithBadPassword")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.system)
            expectation.fulfill()

        }
        wait(for: [expectation], timeout: 20.0)
    }
    
    func testLogin() {
        let email = "test@gmail.com"
        let password = "testing"
        let expectation = XCTestExpectation(description: "Login_Test.testLogin")
        
        try! Auth.auth().signOut()
        Login.login(email: email, password: password) { (user, error) in

            XCTAssertNotNil(user)
            XCTAssertEqual(error.type, Error.ErrorType.none)
            
            try! Auth.auth().signOut()
            expectation.fulfill()

        }
        wait(for: [expectation], timeout: 20.0)
    }
}
