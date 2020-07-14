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
 
 Functions related to the current user signed in with Firebase.
 
 */
class CurrentUser {
    
    /// The current user signed in. `nil` if no user is signed in.
    let user: User? = Auth.auth().currentUser
    
    /**
     
     Determines whether or not there is a user signed in.
     - Returns: Tuple that contains the current user and a bool that indicates whether or not a user is signed in
     
     */
    static func doesExist() -> (User?, Bool) {
        
        guard let user = Auth.auth().currentUser else {
            log.warning(String.CurrentUser.doesExist.logDoesNotExist)
            return (nil, false)
        }
        
        log.debug(String.CurrentUser.doesExist.logExists + user.uid + ".")
        return (user, true)
    }
    
    /**
     
     Signs out the current user.
     - Returns: `Error` that contains
     
     */
    @discardableResult
    static func signOut() -> Error {
        let (user, doesExist) = CurrentUser.doesExist()
        
        if doesExist {
            try! Auth.auth().signOut()
            return Error.error(type: .none, text: String.CurrentUser.signOut.signOut + user!.uid + ".")
        } else {
            return Error.error(type: .weak, text: String.CurrentUser.signOut.doesNotExist)
        }
    }
}
