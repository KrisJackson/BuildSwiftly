//
//  Media.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

/**
 
    Format for media being uploaded to Firebase Storage.
 
 */
struct Media {
    /// Byte buffer for media
    var data: Data!
    
    /// The extension of the media being sent (ex. ".jpg", ".gif", ".png").
    var ext: String!
    
    /// Unique name of media.
    ///
    ///
    /// If the name is the same as another file, the original file will be overridden.
    var name: String!
    
    /// Firebaose Storage reference
    var reference: StorageReference!
}
