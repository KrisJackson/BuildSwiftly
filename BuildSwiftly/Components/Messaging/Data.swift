//
//  Data.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson on 7/13/20.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import UIKit
import Foundation
import Firebase

extension BSMessaging {
    
    enum DataType: String {
        case messages = "Messages"
        case channels = "Channels"
    }
    
    class Data {
        
        var data: [Any] = []
        var type: DataType!
        
        /// Last document retrieved by `get()`
        private var lastDocument: DocumentSnapshot!
        
        
        /**
         
            Initializer takes in the type of data to be retrieved.
         
            - Parameter type: The type of data to be retrieved
         
            - If `.messages`: client should call either `get(forUsers users: [String])` or `get(forChannel channelID: String)` otherwise error.
            - If `.channels`: client should call either `get(forUser user: String)` otherwise error.
         
         */
        init(type: DataType) {
            self.type = type
        }
        
        
        /**
         
          Populates data with messages in a chanel starting at the last document retrieved. The number of messages in the array will not exeed the limit, and all messages are ordered by the timestamp. This function should be called if the client does not have a channel ID, but wishes to retrieve messages in an existing channel.
         
         - Parameter users: The group of users to uniquely identify the channel
         - Parameter limit: The maximum number of data to be added to the array
         
         - This function should ONLY be called if `Data(type: .message)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forUsers users: [String], limit: Int = 0, _ completion: @escaping (_ error: Error) -> Void) {
            // MARK: Handle errors
            
            
            
        }
        
        /**
         
          Populates data with messages in a chanel starting at the last document retrieved. The number of messages in the array will not exeed the limit, and all messages are ordered by the timestamp. This function uses the channelID to retrieve messages in an existing channel.
         
         - Parameter channelID: The unique identifier of an existing channel
         - Parameter limit: The maximum number of data to be added to the array
         
         - This function should ONLY be called if `Data(type: .message)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forChannel channelID: String, limit: Int = 0, _ completion: @escaping () -> Void) {
            // MARK: Handle errors

            
        }
        
        
        /**
         
          Populates data with channel in a channels belonging to a specified user. The number of data in the array will not exeed the limit, and all channels are ordered by `lastTimestamp`.
         
         - Parameter user: The unique identifier of the user
         - Parameter limit: The maximum number of data to be added to the array
         
         - This function should ONLY be called if `Data(type: .channel)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forUser user: String, limit: Int = 0, _ completion: @escaping () -> Void) {
            // MARK: Handle errors

            
        }
        
    }
    
}
