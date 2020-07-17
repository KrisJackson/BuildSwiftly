//
//  SignUp.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

extension BSAuth {
    
    /**
     
     Uses creditials given by the client to assign a unique identifier to a new user.
     
     */
    class SignUp {
        
        /**
         
         Handles user sign up and assigns unique identifier.
         
         - Parameter email: A valid email that the user would like to use to sign into their account.
         - Parameter password: A valid password that the user would like to use to sign into their account.
         - Parameter confirmPassword: Confirms that the user entered the right password. If Client wishes to not use this, pass the password through here.
         - Parameter withExts: Array of email extensions that the Client wished to accept. Most Clients should leave this empty or pass an empty array. Example: Client may only allow users with a Gmail and Yahoo! account, so `ext == ["@gmail.com", "@yahoo.com"]`.
         - Parameter completion: Escapes with `User` and `Error`
         - Parameter user: `User` object created after successful sign up. `nil` if error occurred.
         - Parameter error: Swift `Error` object. `nil` if no error exists.
         
         After a user is successfully created, they are logged in by default. After signing up a new user, it is recommended to immediately sign them out and send verification email.
         
         */
        static func signUp(withEmail e: String, password p: String, confirmPassword c: String, withExts exts: [String] = [], completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
            Logging.log(type: .info, text: "Begin signing up user...")
            
            /// Trim extra white space off
            let email = e.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = p.trimmingCharacters(in: .whitespacesAndNewlines)
            let confirm = c.trimmingCharacters(in: .whitespacesAndNewlines)
            
            /// All fields are required and cannot be empty
            if email.isEmpty || password.isEmpty || confirm.isEmpty {
                Logging.log(type: .warning, text: "All fields must be completed.")
                completion(nil, BSError(description: "All fields must be completed."))
                return
            }
            
            /// Check if password is equal to confirm password
            if (password != confirm) {
                Logging.log(type: .warning, text: "Passwords do not match.")
                completion(nil, BSError(description: "Passwords do not match."))
                return
            }
            
            /// Client has the option to only approve emails with a given set of extensions
            /// Example: Client may only allow users with a Gmail and Yahoo! account, so `ext == ["@gmail.com", "@yahoo.com"]`
            if let extError: BSError = forceExtentsion(email: email, extensions: exts) {
                completion(nil, extError)
                return
            }
            
            /// Firebase function for creating a new user
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    Logging.log(type: .warning, text: error.localizedDescription)
                    completion(nil, BSError(description: error.localizedDescription))
                    return
                }
                
                Logging.log(type: .debug, text: "User account successfully created.")
                completion(Auth.auth().currentUser, nil)
                return
            }
        }
        
        
        /**
         
         Handles user sign up and assigns unique identifier.
         
         - Parameter email:
         - Parameter extensions:
         - Returns: Returns `Error`. If not error, returns `nil`
         
         */
        static private func forceExtentsion(email e: String, extensions exts: [String] = []) -> BSError? {
            
            /// Trims extra whitespace off email
            let email = e.trimmingCharacters(in: .whitespacesAndNewlines)
            
            /// Strips the extension
            let emailExtension = getExtension(email: email)
            
            /// If `extensions` is empty, allow emails of all type to be created.
            if exts.isEmpty {
                return nil
            }
            
            if exts.contains(emailExtension) {
                
                Logging.log(type: .debug, text: "Email contains a valid extension.")
                return nil
                
            } else {
                
                Logging.log(type: .warning, text: "Email does not contain a valid extension.")
                return NMError(description: "Email does not contain a valid extension.")
                
            }
            
        }
        
        
        /**
         
         Get the extension of the email passed. Empty string if no extension.
         
         */
        static private func getExtension(email: String) -> String {
            var e = ""
            for (_, c) in email.enumerated() {
                if (c == "@") || (e.count > 0) {
                    e.append(c)
                }
            }
            return e
        }
        
    }
}

