//
//  Find.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation

extension String {
    
    /// cross-Swift-compatible index
    func find(_ char: Character) -> Index? {
        #if swift(>=5)
            return self.firstIndex(of: char)
        #else
            return self.index(of: char)
        #endif
    }
    
}
