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
    
    /**
     
     Initialize an error.
     
     - Parameter description: A description of the error for debugging.
     
     */
    init(description: String) {
        desc = description
    }
    
    /**
     
     Initialize and log an error.
     
     - Parameter description: A description of the error for debugging.
     - Parameter type: The type of log to be displayed.
     
     */
    init(description: String, logWithType type: Logging.LogType,
         
         file: String = #file,          /// Saves the name of the file that calls `BSError`
         function: String = #function,  /// Saves the name of the function that calls `BSError`
         line: Int = #line              /// Saves the line number that calls `BSError`
        
    ) {
        
        desc = description
        Logging.log(type: type, text: description, file: file, function: function, line: line)
        
    }
    
    
    /// The error description given by the client
    override var description: String {
        get {
            return "Error: \(desc)"
        }
    }
    
    /// The error description given by the client
    var localizedDescription: String? {
        get {
            return self.description
        }
    }
    
}
