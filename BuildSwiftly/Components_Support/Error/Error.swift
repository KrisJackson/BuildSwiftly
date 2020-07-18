//
//  Error.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation

class BSError: NSObject, LocalizedError {
    
    private var desc = ""
    
    init(description: String) {
        desc = description
    }
    
    override var description: String {
        get {
            return "Error: \(desc)"
        }
    }
    
    var localizedDescription: String? {
        get {
            return self.description
        }
    }
    
}
