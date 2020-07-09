//
//  SignUp.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class SignUp {
    
    static func signUp(withEmail e: String, password p: String, confirmPassword c: String, ofType exts: [String] = [], completion: @escaping (User?, Error) -> Void) {
        log.debug(String.SignUp.signUp.logStart)
        
        let email = e.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = p.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirm = c.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email.isEmpty || password.isEmpty || confirm.isEmpty {
            completion(nil, Error.error(type: .weak, text: String.SignUp.signUp.emailEmpty))
            return
        }
        
        if (password != confirm) {
            completion(nil, Error.error(type: .weak, text: String.SignUp.signUp.passwordMatch))
            return
        }
        
        let forceExt = forceExtentsion(email: email, extensions: exts)
        if forceExt.type != .none {
            completion(nil, forceExt)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                completion(Auth.auth().currentUser, Error.error(type: .system, text: error.localizedDescription))
                return
            }
            
            completion(Auth.auth().currentUser, Error.error(type: .none, text: "Account created!"))
            return
        }
    }
    
    static private func forceExtentsion(email e: String, extensions exts: [String] = []) -> Error {
        log.debug(String.SignUp.forceExtentsion.logStart)
        
        let email = e.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailExtension = getExtension(email: email)
        
        if exts.isEmpty {
            
            return Error.error(type: .none, text: "No extensions given")
            
        }
        
        if exts.contains(emailExtension) {
    
            return Error.error(type: Error.ErrorType.none, text: String.SignUp.forceExtentsion.success)
            
        } else {
            
            return Error.error(type: .weak, text: String.SignUp.forceExtentsion.badExt)
            
        }
    }
    
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
