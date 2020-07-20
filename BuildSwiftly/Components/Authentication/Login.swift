//
//  Login.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase


extension BSAuth {
    
    /**
     
     Uses given credenials to sign valid users into the app.
     
     */
    class Login {
        
        /**
        
        Handles signing in a user.
        
        - Parameter email: The verified email that corresponds to a user's account.
        - Parameter password: The password that corresponds to a user's account.
        - Parameter completion: Escapes with the user and any errors.
        - Parameter user: Firebase `User` object that contains metadata about the user's account. `nil` if error.
        - Parameter error: Swift `Error` object. `nil` if no error exists.
        
        */
        static func login(email: String, password: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
            Logging.log(type: .info, text: "Begin logging in user...")
            
            /// Trim extra whitespace off of email and password
            let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let p = password.trimmingCharacters(in: .whitespacesAndNewlines)
            
            /// Handles empty emails
            if e.isEmpty || p.isEmpty {
                Logging.log(type: .warning, text: "Both fields must be completed.")
                completion(nil, BSError(description: "Both fields must be completed."))
                return
            }
            
            /// Firebase function for logging in user. Email and password is passed through and handled by Firebase.
            Auth.auth().signIn(withEmail: e, password: p) { (result, error) in
                if let error = error {
                    Logging.log(type: .warning, text: error.localizedDescription)
                    completion(nil, error)
                    return
                }
                
                /// User successfully logged in
                Logging.log(type: .debug, text: "User has been successfully logged in.")
                completion(Auth.auth().currentUser, nil)
            }
        }
    }
}

