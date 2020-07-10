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
    
    typealias FileCompletionBlock = () -> Void
    private static var block: FileCompletionBlock?
    
    /// Send a batch of files to Firebase Storage.
    static func upload(media: [Media], atPath path: StorageReference, _ completion: @escaping FileCompletionBlock) {
        
        if media.count == 0 {
            completion()
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
            
            FirFile.shared.upload(data: media[index].data, withName: fileName, atPath: path, block: { (url) in
                
                /// After successfully uploading, call this method again by incrementing the **index = index + 1**
                log.warning(url ?? "Couldn't not upload.")
                self.store(media: media, atPath: path, forIndex: index + 1)
                
            })
            return
            
        }
        
        if block != nil { block!() }
        
    }
    
}
