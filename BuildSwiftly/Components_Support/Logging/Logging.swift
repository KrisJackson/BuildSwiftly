//
//  Logging.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson on 7/17/20.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation

/**
 
 
 Class for logging in a more neat and user-friendly way.
 
 This class was inspired by BuildSwiftly repo.
 
 */
class Logging {
    
    enum LogType {
        case verbose
        case debug
        case info
        case warning
        case error
    }
    
    static func log(type: LogType, text: Any, file: String = #file, function: String = #function, line: Int = #line) {
        
        var emoji = ""
        switch type {
        case .verbose:
            emoji = "🟣 VERBOSE"
        case .debug:
            emoji = "🟢 DEBUG"
        case .info:
            emoji = "🔵 INFO"
        case .warning:
            emoji = "🟡 WARNING"
        case .error:
            emoji = "🔴 ERROR"
        }
        
        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        
//        print("\(localDate) => \(emoji) => \(stripParams(function: function)) => \(line) - \(text)")
        print("\(localDate) => \(emoji) => \(function) => \(line) - \(text)")
    }
    
    /// removes the parameters from a function
    private func stripParams(function: String) -> String {
        var f = function
        if let indexOfBrace = f.find("(") {
            #if swift(>=4.0)
            f = String(f[..<indexOfBrace])
            #else
            f = f.substring(to: indexOfBrace)
            #endif
        }
        f += "()"
        return f
    }
}
