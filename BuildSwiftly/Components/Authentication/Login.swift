//
//  Login.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class Login {
    static func login(email e: String, password p: String, completion: @escaping (_ user: User?, _ error: Error) -> Void) {
        log.debug(String.Login.login.logStart)
        
        let email = e.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = p.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty || password.isEmpty {
            completion(nil, Error.error(type: .weak, text: String.Login.login.emptyFields))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(Auth.auth().currentUser, Error.error(type: .system, text: error.localizedDescription))
                return
            }
            
            completion(Auth.auth().currentUser, Error.error(type: .none, text: String.Login.login.success))
            return
        }
    }
}

