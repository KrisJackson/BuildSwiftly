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
            
            /// Reference to the messages pointing to a given channelID
            var messagesRef = Firestore.firestore().collection(String.Database.Messaging.collectionID)
                .whereField(String.Database.Messaging.channelID, isEqualTo: channelID)
                .order(by: String.Database.Messaging.timestamp, descending: false)
            
            /// If `limit == 0` get all messages in the given query
            if limit > 0 {
                messagesRef = messagesRef.limit(to: limit)
            }
            
            /// If value exists, start at last document
            if let lastDocument = lastDocument {
                messagesRef = messagesRef.start(afterDocument: lastDocument)
            }
            
            /// Populate data with messages
            messagesRef.addSnapshotListener { (snapshot, error) in /// Listener allows for real-time updates
                
                if let error = error {
                    completion(Error.error(type: .system, text: error.localizedDescription))
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(Error.error(type: .none, text: "No messages to collect."))
                    return
                }
                
                self.populateMessageData(snapshot: snapshot)
                
                completion(Error.error(type: .none, text: "Message data have been collected!"))
                
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
        
        /**
         
         PRIVATE: Collects messages and appends to `data`. Also saves the last document collected.
         
         - Parameter snapshot: The collection messages after the query has been performed
         
         */
        private func populateMessageData(snapshot: QuerySnapshot) {
            
            var last: DocumentSnapshot!
            for document in snapshot.documents {
                
                /// Get message
                var message = BSMessage()
                message.messageID = document.documentID
                message.channelID = document.data()[String.Database.Messaging.channelID] as? String
                message.mediaID = document.data()[String.Database.Messaging.media] as? [String]
                message.replyToUID = document.data()[String.Database.Messaging.replyTo] as? String
                message.senderUID = document.data()[String.Database.Messaging.sender] as? String
                message.text = document.data()[String.Database.Messaging.text] as? String
                message.timestamp = document.data()[String.Database.Messaging.timestamp] as? Double
                message.users = document.data()[String.Database.Messaging.users] as? [String]
                
                /// Store message
                data.append(message)
                
                /// Record each document
                last = document
                
            }
            
            /// Saves the last document
            self.lastDocument = last
            
        }
        
    } /* Data - END */
    
} /* BSMessaging - END */
