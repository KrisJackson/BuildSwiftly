//
//  Verification.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class Verification {
    
    static func isVerified(user: User = Auth.auth().currentUser!) -> (User, Bool) {
        var message: String!
        if user.isEmailVerified {
            message = String.Verification.isVerified.emailVerified
        } else {
            message = String.Verification.isVerified.emailNotVerified
        }
        
        log.warning(message)
        return (user, user.isEmailVerified)
    }
    
    static func send(user: User = Auth.auth().currentUser!, completion: @escaping (Error) -> Void) {
        log.debug("Begin verification...")
        
        user.sendEmailVerification { (error) in
            if let error = error {
                
                log.warning(error.localizedDescription)
                completion(Error.error(type: .system, text: error.localizedDescription))
                
            } else {
                
                log.info(String.Verification.send.logSent + (user.email ?? "") + ".")
                completion(Error.error(type: .none, text: String.Verification.send.sent + "\(user.email ?? ""). " + String.Verification.send.spam))
                
            }
        }
    }
}
