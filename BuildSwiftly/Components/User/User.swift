//
//  User.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

/**
 
 Stores and retrieves data corresponding to a generic user's account.
 
 */
class BSUser {
    
    /**
     
     Determines whether or not a user exists given a uid.
     
     */
    func store(data: [String: Any], forUserID uid: String, _ completion: @escaping (_ error: Error?) -> Void) {
        Firestore.firestore().collection(String.Database.Users.collectionID)
            .document(uid).setData(data, merge: true) { (error) in
                
                guard let error = error else { completion(nil); return }
                completion(error)
        }
    }
    
    
    /**
     
     
     
     */
    func getData(forUserID uid: String, _ completion: @escaping (_ data: [String: Any]?, _ error: Error?) -> Void) {
        Firestore.firestore().collection(String.Database.Users.collectionID).document(uid).getDocument { (snapshot, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot else {
                completion(nil, BSError(description: "No data for user."))
                return
            }
            
            completion(snapshot.data(), nil)
            
        }
        
    }
    
    
}
