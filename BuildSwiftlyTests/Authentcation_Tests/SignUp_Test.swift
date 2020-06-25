//
//  SignUp_Test.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import XCTest
import Firebase
@testable import BuildSwiftly

class SignUp_Test: XCTestCase {

    func testWrongEmailExtension() {
        let email = "random@gmail.com"
        let password = "FakePassword"
        let extensions = ["@test.com", "@testing.com"]
        let expectation = XCTestExpectation(description: "SignUp_Test.testEmptyPassword")
            
        try! Auth.auth().signOut()
        SignUp.signUp(withEmail: email, password: password, confirmPassword: password, ofType: extensions) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.weak)
            
            try! Auth.auth().signOut()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEmptyEmail() {
        let email = ""
        let password = "FakePassword"
        let expectation = XCTestExpectation(description: "SignUp_Test.testEmptyPassword")
            
        try! Auth.auth().signOut()
        SignUp.signUp(withEmail: email, password: password, confirmPassword: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.weak)
            
            try! Auth.auth().signOut()
            expectation.fulfill()
        }
            
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testBadEmailFormat() {
        let email = "testing@"
        let password = "FakePassword"
        let expectation = XCTestExpectation(description: "SignUp_Test.testEmptyPassword")
          
        try! Auth.auth().signOut()
        SignUp.signUp(withEmail: email, password: password, confirmPassword: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.system)
            
            try! Auth.auth().signOut()
            expectation.fulfill()
        }
            
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testEmptyPassword() {
        let email = "random@gmail.com"
        let password = ""
        let expectation = XCTestExpectation(description: "SignUp_Test.testEmptyPassword")
        
        try! Auth.auth().signOut()
        SignUp.signUp(withEmail: email, password: password, confirmPassword: password) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.weak)
            
            try! Auth.auth().signOut()
            expectation.fulfill()
        }
            
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPasswordsNotEqual() {
        let email = "random@gmail.com"
        let password = "password1"
        let confirmPassword = "password2"
        let expectation = XCTestExpectation(description: "SignUp_Test.testEmptyPassword")
        
        try! Auth.auth().signOut()
        SignUp.signUp(withEmail: email, password: password, confirmPassword: confirmPassword) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.weak)
            
            try! Auth.auth().signOut()
            expectation.fulfill()
        }
            
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testUsedAccount() {
        let email = "test@gmail.com"
        let password = "testing"
        let confirmPassword = "testing"
        let expectation = XCTestExpectation(description: "SignUp_Test.testEmptyPassword")
        
        try! Auth.auth().signOut()
        SignUp.signUp(withEmail: email, password: password, confirmPassword: confirmPassword) { (user, error) in
            
            XCTAssertNil(user)
            XCTAssertNotEqual(error.type, Error.ErrorType.none)
            XCTAssertEqual(error.type, Error.ErrorType.system)
            
            try! Auth.auth().signOut()
            expectation.fulfill()
        }
            
        wait(for: [expectation], timeout: 10.0)
    }
    
}
