//
//  Object.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson on 7/8/20.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation

class Object: NSObject, NSDiscardableContent {
    func endContentAccess() {}
    func discardContentIfPossible() {}
    func beginContentAccess() -> Bool { return true }
    func isContentDiscarded() -> Bool { return false }
}
