//
//  UserStore.swift
//
//  Created by Kristopher Jackson.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class UserStore {
    
    static func store(data: [String: Any], forUser user: User = Auth.auth().currentUser!, _ completion: @escaping (Error) -> Void) {
        log.debug("Begin storing user data...")

        Firestore.firestore().collection("users").document(user.uid).setData(data, merge: true) { (error) in
            if let error = error {
                log.warning(error.localizedDescription)
                completion(Error.error(type: .system, text: error.localizedDescription))
                return
            }
            completion(Error.error(type: .weak, text: "User does not exist."))
            return
        }
    }
    
    static func doesDocumentExist(forUser user: User, _ completion: @escaping (Bool?, Error) -> Void) {
        log.debug("Checking if user exists...")
        
        Firestore.firestore().collection("users").document(user.uid).getDocument { (snapshot, error) in

            if let error = error {
                log.warning(error.localizedDescription)
                completion(nil, Error.error(type: .system, text: error.localizedDescription))
                return
            }
            
            guard let snapshot = snapshot else {
                log.error("There seems to have been error retrieving the user.")
                completion(nil, Error.error(type: .system, text: "There seems to have been error retrieving the user."))
                return
            }
            
            log.info("User document exists!")
            completion(snapshot.exists, Error.error(type: .none, text: "Document successfully retrieved!"))
        }
    }

    
}

