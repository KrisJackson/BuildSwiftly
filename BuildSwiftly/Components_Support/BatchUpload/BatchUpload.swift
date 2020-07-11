//
//  BatchUpload.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//
//
// Code from https://stackoverflow.com/questions/49934195/how-to-upload-multiple-image-on-firebase-using-swift

import Foundation
import Firebase

/**
 
 Recursively send a batch of data to Firebase Storage.
 
 */
class Batch {
    
    typealias FileCompletionBlock = (Error) -> Void
    private static var block: FileCompletionBlock?
    
    /// Send a batch of files to Firebase Storage.
    static func upload(media: [Media], atPath path: StorageReference, _ completion: @escaping FileCompletionBlock) {
        
        if media.count == 0 {
            completion(Error.error(type: .weak, text: "There are no items in media to store."))
            return
        }

        block = completion
        store(media: media, atPath: path, forIndex: 0)

    }
    
    private static func store(media: [Media], atPath path: StorageReference, forIndex index: Int) {
         if index < media.count {
            
            let buf = media[index]
            let fileName = String(format: "\(buf.name ?? "unnamed-file-\(index)").\(buf.ext ?? ".txt")")
            if let _ = buf.name {} else { log.warning("Media does not have a name.") }
            
            /// If data is `nil` then it does not exist
            /// Could happen if there is a typo in the file name or if extension is wrong
            guard let data = media[index].data else {
                block!(Error.error(type: .weak, text: "Data does not exist!"))
                return
            }
            
            /// Begin uploading data to Firebase Storage. 
            FirFile.shared.upload(data: data, withName: fileName, atPath: path, block: { (url, error) in
                switch error.type {
                case .none:
                    
                    self.store(media: media, atPath: path, forIndex: index + 1)
                    break
                    
                default:
                    
                    block!(Error.error(type: error.type, text: error.text))
                    break
                    
                }
            })
            return
            
        }
        
        if block != nil { block!(Error.error(type: .none, text: "Successfully added media to Firebase Storage!")) }
        
    }
    
}
