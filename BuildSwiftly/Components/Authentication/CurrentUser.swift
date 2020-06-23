//
//  SignOut.swift
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class CurrentUser {
    
    let user: User? = Auth.auth().currentUser
    
    static func doesExist() -> (User?, Bool) {
        guard let user = Auth.auth().currentUser else {
            log.warning(String.CurrentUser.doesExist.logDoesNotExist)
            return (nil, false)
        }
        log.info(String.CurrentUser.doesExist.logExists + user.uid + ".")
        return (user, true)
    }
    
    @discardableResult static func signOut() -> Error {
        let (user, doesExist) = CurrentUser.doesExist()
        
        if doesExist {
            try! Auth.auth().signOut()
            log.info(String.CurrentUser.signOut.logSignOut + user!.uid + ".")
            return Error.error(type: .none, text: String.CurrentUser.signOut.signOut + user!.uid + ".")
        } else {
            log.warning(String.CurrentUser.signOut.doesNotExist)
            return Error.error(type: .weak, text: String.CurrentUser.signOut.doesNotExist)
        }
    }
}
