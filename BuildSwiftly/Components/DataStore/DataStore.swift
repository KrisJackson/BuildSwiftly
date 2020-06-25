//
//  DataStore.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class DataStore {
    
    func store(data: [String: Any], inCollection collection: String, withID document: String? = nil, _ completion: @escaping (Error) -> Void) {
        log.debug("Begin storing data...")
        
        var documentRef: DocumentReference!
        let collectionRef = Firestore.firestore().collection(collection)
        
        if let document = document {
            documentRef = collectionRef.document(document)
        } else { documentRef = collectionRef.document() }
        
        if data.isEmpty {
            log.warning("Cannot store empty data.")
            completion(Error.error(type: .weak, text: "Cannot store empty data."))
            return
        }
        
        documentRef.setData(data, merge: true) { (error) in
            guard let error = error else {
                log.debug("Successfully stored data.")
                completion(Error.error(type: .none, text: "Successfully stored data."))
                return
            }
            
            log.warning(error.localizedDescription)
            completion(Error.error(type: .none, text: error.localizedDescription))
            return
        }
        
    }
    
    func get() {
        
    }
    
    func delete() {
        
    }
    
}


