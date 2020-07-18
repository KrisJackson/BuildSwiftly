//
//  SignOut.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

/**
 
 Set of components that handles signing up, logging in, verifying, retrieving and creating a user.
 
 This component should be called anytime the client needs to store or retieve any data regarding a user.
 
 */
class BSAuth {
    
    /**
     
     Gathers data related to the current user and handles sign out.
     
     This class is useful when needing a quick reference to metadata related to the current users.
     
     */
    class CurrentUser {
        
        /// Metadata related to the current user.
        ///
        ///
        /// - Variable will return `nil` if there is no current user
        /// - `User` is an object created by Firebase.
        let user: User? = Auth.auth().currentUser
        
        
        /**
         
         Determines whether or not there is a current user signed into the app.
         
         - Returns: A tuple consisting an *optional* `User` object and a boolean value indicating whether or not a user is signed in.
         
         - If user does not exist, `User` is `nil`
         
         */
        static func doesExist() -> (User?, Bool) {
            guard let user = Auth.auth().currentUser else {
                return (nil, false)
            }
            return (user, true)
        }
        
        
        /**
         
         Signs out the current user if one exists.
         
         */
        static func signOut() {
            let (user, doesExist) = CurrentUser.doesExist()
            
            /// User exists
            if doesExist {
                
                let uid = user?.uid
                try! Auth.auth().signOut() /// Firebase sign out function call
                Logging.log(type: .debug, text: String.BSAuth.CurrentUser.signOut_success(uid: uid ?? ""))
                
            } else {
            
                Logging.log(type: .warning, text: "User does not exist. Cannot be signed out.")
                
            }
        }
    }
}
