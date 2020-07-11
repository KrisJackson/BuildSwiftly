//
//  FirFile.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//
//
// Code from https://stackoverflow.com/questions/49934195/how-to-upload-multiple-image-on-firebase-using-swift

import Foundation
import Firebase

class FirFile: NSObject {

    /// Singleton instance
    static let shared: FirFile = FirFile()

    /// Current uploading task
    var currentUploadTask: StorageUploadTask?
    

    func upload(data: Data, withName fileName: String, atPath path: StorageReference, block: @escaping (_ url: URL?, _ error: Error) -> Void) {
        
        // Upload the file to the path
        self.currentUploadTask = path.child(fileName).putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                block(nil, Error.error(type: .system, text: error.localizedDescription))
                return
             }
            
             // Metadata contains file metadata such as size, content-type.
             // let size = metadata.size
             // You can also access to download URL after upload.
            
             path.child(fileName).downloadURL { (url, error) in
                guard let url = url else {
                    block(nil, Error.error(type: .system, text: error?.localizedDescription))
                    return
                }
                block(url, Error.error(type: .none, text: "File successfully uploaded to Firebase Storage!"))
             }
        }
    }

    func cancel() {
        self.currentUploadTask?.cancel()
    }
}
