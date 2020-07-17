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
        
        /// Data to be populated. This data can either be `BSMessage` or `BSChannel`.
        var data: [Any] = []
        
        
        /// The type of data being stored.
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
         - Parameter limit: The maximum number of data to be added to the array. If **limit == 0** add all data to array .
         - Parameter completion: Escapes with `Error`
         - Parameter error: Contains a message and the error type upon completion
         
         - This function should ONLY be called if `Data(type: .message)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forUsers users: [String], limit: Int = 0, _ completion: @escaping (_ error: Error?) -> Void) {
            
            // MARK: Handle errors (if .channel was passed and this function was called)
            
            /// Gets the channel with the given set of users
            Channel.doesChannelExist(withUsers: users) { (exists, channel, error) in
                
                /// Handle errors
                guard let exists = exists else { completion(error); return }
                guard let channel = channel else { completion(error); return }
                
                /// Channel does not exist for the set of users
                if !exists { completion(error); return }
                
                /// Handles empty channelID
                if (channel.channelID ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Logging.log(type: .warning, text: "ChannelID cannot be empty.")
                    completion(BSError(description: "ChannelID cannot be empty."))
                    return
                }
                
                /// Get messages with channel ID
                self.get(forChannel: channel.channelID ?? "", limit: limit) { (error) in
                    completion(error)
                }
                    
            }
            
        }
        
        
        /**
         
          Populates data with messages in a chanel starting at the last document retrieved. The number of messages in the array will not exeed the limit, and all messages are ordered by the timestamp. This function uses the channelID to retrieve messages in an existing channel.
         
         - Parameter channelID: The unique identifier of an existing channel
         - Parameter limit: The maximum number of data to be added to the array. If **limit == 0** add all data to array .
         - Parameter completion: Escapes with `Error`
         - Parameter error: Contains a message and the error type upon completion
         
         - This function should ONLY be called if `Data(type: .message)` was passed.
         - The array uses a listener to populate the data, and will check periodically for new messages.
         
         */
        func get(forChannel channelID: String, limit: Int = 0, _ completion: @escaping (_ error: Error?) -> Void) {
            
            // MARK: Handle errors (if .channel was passed and this function was called)
            
            /// Reference to the messages pointing to a given channelID
            var messagesRef = Firestore.firestore().collection(String.Database.Messaging.collectionID)
                .whereField(String.Database.Messaging.channelID, isEqualTo: channelID)
                .order(by: String.Database.Messaging.timestamp, descending: false)
            
            if limit > 0 {
                messagesRef = messagesRef.limit(to: limit)
            }
            
            if let lastDocument = lastDocument {
                messagesRef = messagesRef.start(afterDocument: lastDocument)
            }
            
            /// Populate data with messages
            self.populateData(fromReference: messagesRef) { (document) -> Any in
                
                var message = BSMessage()
                message.messageID = document.documentID
                message.channelID = document.data()[String.Database.Messaging.channelID] as? String
                message.mediaID = document.data()[String.Database.Messaging.media] as? [String]
                message.replyToUID = document.data()[String.Database.Messaging.replyTo] as? String
                message.senderUID = document.data()[String.Database.Messaging.sender] as? String
                message.text = document.data()[String.Database.Messaging.text] as? String
                message.timestamp = document.data()[String.Database.Messaging.timestamp] as? Double
                message.users = document.data()[String.Database.Messaging.users] as? [String]
                return message
                
            }
                
            Logging.log(type: .debug, text: "Message data has been collected!")
            completion(nil)
            
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
        func get(forUser user: String, limit: Int = 0, _ completion: @escaping (_ error: Error?) -> Void) {
            
            // MARK: Handle errors (if .messages was passed and this function was called)
            
            /// Reference to the messages pointing to a given channelID
            var channelsRef = Firestore.firestore().collection(String.Database.Messaging.collectionID)
                .whereField(String.Database.Channel.users, arrayContains: user)
                .order(by: String.Database.Messaging.timestamp, descending: false)
            
            if limit > 0 {
                channelsRef = channelsRef.limit(to: limit)
            }
            
            if let lastDocument = lastDocument {
                channelsRef = channelsRef.start(afterDocument: lastDocument)
            }
            
            /// Populate data with channels
            self.populateData(fromReference: channelsRef) { (document) -> Any in
                
                var channel = BSChannel()
                channel.channelID = document.documentID
                channel.admin = document.data()[String.Database.Channel.admin] as? [String]
                channel.author = document.data()[String.Database.Channel.author] as? String
                channel.created = document.data()[String.Database.Channel.created] as? Double
                channel.lastMedia = document.data()[String.Database.Channel.lastMedia] as? [String]
                channel.lastReplyTo = document.data()[String.Database.Channel.lastReplyTo] as? String
                channel.lastSender = document.data()[String.Database.Channel.lastSender] as? String
                channel.lastText = document.data()[String.Database.Channel.lastText] as? String
                channel.lastTimestamp = document.data()[String.Database.Channel.lastTimestamp] as? Double
                channel.users = document.data()[String.Database.Channel.users] as? [String]
                return channel
                
            }
            
            Logging.log(type: .debug, text: "Channel data has been collected.")
            completion(nil)
        }
        
        
        /**
         
         PRIVATE: Retrieves data and appends to `data`. Also saves the last document collected.
         
         - Parameter snapshot: The collection messages after the query has been performed
         - Parameter completion: Escapes with document in the query
         - Parameter document: Document containing data from the query. Client should extract and return data in desired format.
         
         */
        
        private func populateData(fromReference ref: Query, _ completion: @escaping (_ document: QueryDocumentSnapshot) -> Any) {
            
            /// Populates `data` with messages
            ref.addSnapshotListener { (snapshot, error) in /// **Listener** allows for real-time updates
                
                /// If error, data should just be empty
                if error != nil { return }
                guard let snapshot = snapshot else { return }
                
                /// Iterate through every document
                for document in snapshot.documents {
                    self.data.append(completion(document))
                    self.lastDocument = document
                }
                
            }
        
        }
        
    }
    
} 
