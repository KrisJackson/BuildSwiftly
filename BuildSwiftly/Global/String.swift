//
//  String.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation

// Login API
extension String {
    
    class Login {
        
        struct login {
            static let logStart = "Begin authentication..."
            static let success = "User has successfully logged in!"
            static let emptyFields = "All fields must be completed!"
            static let logEmptyFields = "Email or password is empty."
            static let logSuccess = "User has successfully logged in!"
        }
        
    }
    
}

// Verification API
extension String {
    
    class Verification {
        
        struct isVerified {
            static let emailVerified = "User email verified!"
            static let emailNotVerified = "User email is not verified"
            static let logNoUser = "No user specified!"
        }
        
        struct send {
            static let emailRequired = "Email is required!"
            static let hasBeenVerified = "Email has already been verified."
            static let logStart = "Preparing to send email..."
            static let logEmailEmpty = "Email is empty"
            static let logEmailVerified = "Email has been verified."
            static let logSent = "Verification email successfully sent to "
            static let spam =  "Be sure to check you spam folder and click the link in the email."
            static let sent = "A verification email has been sent to "
        }
        
    }
    
}

// Sign Up API
extension String {
    
    class SignUp {
        
        struct signUp {
            static let logStart = "Creating user..."
            static let logEmailEmpty = "Email or password is empty"
            static let emailEmpty = "All fields must be completed!"
            static let logPasswordMatch = "Passwords do not match"
            static let passwordMatch = "Passwords must match!"
        }
        
        struct forceExtentsion {
            static let logStart = "Checking extension..."
            static let logSuccess = "Email extension valid."
            static let success = "This email is supported!"
            static let logBadExt = "Email does not contain a valid extension."
            static let badExt = "This email address is not supported. Please enter your provided work email."
        }
        
    }
    
}

// Current User API
extension String {
    
    class CurrentUser {
        
        struct doesExist {
            static let logDoesNotExist = "User does not exist."
            static let logExists = "User exists with id "
        }
        
        struct signOut {
            static let logSignOut = "Signed out user with id "
            static let signOut = "Successfully signed out user with id"
            static let doesNotExist = "User does not exist."
        }
        
    }
    
}
