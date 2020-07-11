//
//  Error.swift
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import SwiftyBeaver

class Error {
    
    var text: String? = nil
    var type: ErrorType = .undefined
    
    enum ErrorType {
        // No error present
        case none
        // Error thrown by third party API
        case system
        // Non-fatal error that should be handled by UI
        case weak
        // Something unexpected happened that's potentially fatal
        case fatal
        // Default value when no error is defined by programmer. Should be handled
        case undefined
    }
    
    static func error(type: ErrorType = .undefined, text: String? = nil) -> Error {
        let err = Error()
        err.type = type
        err.text = text
        
        switch type {
        case .none:
            log.debug(text ?? "Success!")
            break
        case .fatal:
            log.error(text ?? "Fatal error!")
            break
        default:
            log.warning(text ?? "Flag!")
            break
        }
        
        return err
    }
    
}
