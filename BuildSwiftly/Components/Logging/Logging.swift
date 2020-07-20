//
//  Logging.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson 
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
        
//        print("\(localDate) => \(emoji) => \(stripParams(function: function)) => \(line) - \(text)")
        print("\(getDate()) => \(emoji) => \(function) => \(line) - \(text)")
    }
    
    /// Removes the parameters from a function.
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
    
    /// Gets the current date and time and returns as a string.
    private static func getDate() -> String {
        let date = Date(timeIntervalSince1970: Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}
