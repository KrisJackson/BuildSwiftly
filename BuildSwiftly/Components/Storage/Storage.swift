//
//  FirFile.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class BSStorage: NSObject {

    /// Singleton instance
    static let shared: BSStorage = BSStorage()

    /// Current uploading task
    var currentUploadTask: StorageUploadTask?
    

    func upload(data: Data, withName fileName: String, atPath path: StorageReference, block: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        
        /// Upload the file to the path
        self.currentUploadTask = path.child(fileName).putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                block(nil, error)
                return
             }
            
             /// Metadata contains file metadata such as size, content-type.
             /// let size = metadata.size
             /// You can also access to download URL after upload.
             path.child(fileName).downloadURL { (url, error) in
                guard let url = url else {
                    Logging.log(type: .warning, text: error?.localizedDescription ?? "Could not download url.")
                    block(nil, error)
                    return
                }
                Logging.log(type: .debug, text: "File successfully uploaded to Firebase Storage.")
                block(url, nil)
             }
        }
    }

    func cancel() {
        self.currentUploadTask?.cancel()
    }
}
