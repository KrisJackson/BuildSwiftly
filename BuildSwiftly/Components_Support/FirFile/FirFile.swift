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

    /// Firebase Storage path
    let kFirFileStorageRef = Storage.storage().reference().child("Files")

    /// Current uploading task
    var currentUploadTask: StorageUploadTask?

    func upload(data: Data, withName fileName: String, block: @escaping (_ url: URL?) -> Void) {
        
        // Create a reference to the file you want to upload
        let fileRef = kFirFileStorageRef.child(fileName)

        // Start uploading
        upload(data: data, withName: fileName, atPath: fileRef) { (url) in
            block(url)
        }
    }

    func upload(data: Data, withName fileName: String, atPath path: StorageReference, block: @escaping (_ url: URL?) -> Void) {
        
        // Upload the file to the path
        self.currentUploadTask = path.putData(data, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                  // Uh-oh, an error occurred!
                  block(nil)
                  return
             }
            
             // Metadata contains file metadata such as size, content-type.
             // let size = metadata.size
             // You can also access to download URL after upload.
             path.downloadURL { (url, error) in
                guard url != nil else {
                     // Uh-oh, an error occurred!
                     block(nil)
                     return
                }
                block(url)
             }
        }
    }

    func cancel() {
        self.currentUploadTask?.cancel()
    }
}
