//
//  UserStore.swift
//
//  Created by Kristopher Jackson.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

extension BSAuth {
    /**
     
     Handles the store and retrieval of data belonging to a given user.
     
     */
    class UserStore {
        
        /**
         
         Appends data to a given user's document.
         
         - Parameter data: Dictionary containing data to be stored in the user's profile.
         - Parameter user: Firebase `User`object that data will be added.
         - Parameter completion: Escapes with error
         - Parameter error: Swift `Error` object. `nil` if no error exists.
         
         */
        static func store(data: [String: Any], forUser user: User? = Auth.auth().currentUser, _ completion: @escaping (_ error: Error?) -> Void) {
            Logging.log(type: .info, text: "Begin storing user data...")
            
            /// Verifies that the user exists
            guard let user = user else {
                Logging.log(type: .warning, text: "User does not exist.")
                completion(BSError(description: "User does not exist."))
                return
            }
            
            /// Firebase function called to merge data to user's profile
            Firestore.firestore().collection("users").document(user.uid).setData(data, merge: true) { (error) in
                if let error = error {
                    
                    /// Handles error
                    Logging.log(type: .warning, text: error.localizedDescription)
                    completion(BSError(description: error.localizedDescription))
                    
                } else { completion(nil) }
            }
        }
        
        /**
         
         Determines whether or not a document exists.
         
         - Parameter user: Firebase `User`object that will be used to determine whether or not a document exists.
         - Parameter completion: Escapes with a bool and error.
         - Parameter exists: Bool that determines whether or not the user's document exists.
         - Parameter error: Swift `Error` object. `nil` if no error exists.
         
         */
        static func doesDocumentExist(forUser user: User, _ completion: @escaping (_ exists: Bool?, _ error: Error?) -> Void) {
            Logging.log(type: .debug, text: "Checking if user exists...")
            
            Firestore.firestore().collection("users").document(user.uid).getDocument { (snapshot, error) in

                /// Handles error
                if let error = error {
                    Logging.log(type: .warning, text: error.localizedDescription)
                    completion(nil, BSError(description: error.localizedDescription))
                    return
                }
                
                /// Verifies that a snapshot exists
                guard let snapshot = snapshot else {
                    Logging.log(type: .warning, text: "There seems to have been error retrieving the user.")
                    completion(nil, BSError(description: "There seems to have been error retrieving the user."))
                    return
                }
                
                /// Logs result
                if snapshot.exists {
                    Logging.log(type: .debug, text: "User document exists.")
                } else{
                    Logging.log(type: .warning, text: "User document does not exist.")
                }
                
                completion(snapshot.exists, nil)
                
            }
        }
        
        
        // MARK: - Add default user data
        // TODO: Add default user data
        
        

        // MARK: - Get user data
        // TODO: Get user data
        
        
        
    }
}
