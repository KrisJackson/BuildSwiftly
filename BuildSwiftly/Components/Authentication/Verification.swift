//
//  Verification.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

extension BSAuth {
    
    /**
     
     Contains methods to verify a user's account.
     
     */
    class Verification {

        /**
         
         Determines whether or not a user is verified.
         
         - Parameter user: Firebase `User` object to determine whether or not a user is verified.
         - Returns: Return a bool stating whether or not they are verified
         
         */
        static func isVerified(user: User = Auth.auth().currentUser!) -> (User, Bool) {
            return (user, user.isEmailVerified)
        }

        
        /**
         
         Send a verification email to the given email address.
         
         */
        static func sendTo(user: User? = Auth.auth().currentUser, completion: @escaping (Error?) -> Void) {
            Logging.log(type: .info, text: "Begin verification...")

            /// Verifies that a user have been given
            guard let user = user else {
                Logging.log(type: .warning, text: "User does not exist.")
                completion(BSError(description: "User does not exist."))
                return
            }

            /// Firebase function that sends email verification
            user.sendEmailVerification { (error) in
                if let error = error {
            
                    /// Error
                    Logging.log(type: .warning, text: error.localizedDescription)
                    completion(BSError(description: error.localizedDescription))

                } else {

                    /// Email sent
                    Logging.log(type: .debug, text: "Email has been sent to \(user.email ?? ""). Be sure to check spam or junk folder if the email has not been received.")
                    completion(nil)

                }
            }
        }
    }
}
