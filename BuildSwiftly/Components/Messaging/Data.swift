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
        private var lastDocument: DocumentReference!
        
        
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
         - Parameter completion: Escapes with `Error`
         - Parameter error: Contains a message and the error type upon completion
         
         - This function should ONLY be called if `Data(type: .message)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forUsers users: [String], limit: Int = 0, _ completion: @escaping (_ error: Error) -> Void) {
            
            // MARK: Handle errors (if .channel was passed and this function was called)
            
            /// Gets the channel with the given set of users
            Channel.doesChannelExist(withUsers: users) { (exists, channel, error) in
                
                /// Handle errors
                guard let exists = exists else { completion(error); return }
                guard let channel = channel else { completion(error); return }
                
                /// Channel does not exist for the set of users
                if !exists { completion(error); return }
                
                /// Get messages with channel ID
                self.get(forChannel: channel.channelID ?? "", limit: limit) { (error) in
                    completion(error)
                }
                    
            }
            
        }
        
        /**
         
          Populates data with messages in a chanel starting at the last document retrieved. The number of messages in the array will not exeed the limit, and all messages are ordered by the timestamp. This function uses the channelID to retrieve messages in an existing channel.
         
         - Parameter channelID: The unique identifier of an existing channel
         - Parameter limit: The maximum number of data to be added to the array
         - Parameter completion: Escapes with `Error`
         - Parameter error: Contains a message and the error type upon completion
         
         - This function should ONLY be called if `Data(type: .message)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forChannel channelID: String, limit: Int = 0, _ completion: @escaping (_ error: Error) -> Void) {
            // MARK: Handle errors (if .channel was passed and this function was called)
            
            /// Handles empty channelID
            if channelID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                completion(Error.error(type: .weak, text: "ChannelID cannot be empty."))
                return
            }
            
            /// Populates data with more messages starting at the last document.
            if let lastDocument = lastDocument {
                
                /// Start from the beginning if last document is not given
                populateMessageData(withLastDocument: lastDocument, limit: limit) { (error) in
                    completion(error)
                }
                
            } else {
                
                /// Pick up where left off
                populateMessageData(limit: limit) { (error) in
                    completion(error)
                }
            }
            
        }
        
        
        /**
         
          Populates data with channel in a channels belonging to a specified user. The number of data in the array will not exeed the limit, and all channels are ordered by `lastTimestamp`.
         
         - Parameter user: The unique identifier of the user
         - Parameter limit: The maximum number of data to be added to the array
         - Parameter completion: Escapes with `Error`
         - Parameter error: Contains a message and the error type upon completion
         
         - This function should ONLY be called if `Data(type: .channel)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forUser user: String, limit: Int = 0, _ completion: @escaping (_ error: Error) -> Void) {
            // MARK: Handle errors (if .messages was passed and this function was called)

            
        }
        
        
        private func populateMessageData(limit: Int, _ completion: @escaping (_ error: Error) -> Void) {
            
        }
        
        private func populateMessageData(withLastDocument: DocumentReference, limit: Int, _ completion: @escaping (_ error: Error) -> Void) {
            
        }
    }
    
}
