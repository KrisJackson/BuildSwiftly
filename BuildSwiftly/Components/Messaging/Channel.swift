//
//  Channel.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Firebase
import FirebaseFirestore
import Foundation

extension BSMessaging {
    
    /**
     
     Channels can be thought of as 'chat rooms' and keeps track of important metadata related to a specific chat. Each message should point to a channel.
     
     One common usage of channels may be when configuring an Inbox for your app. Rather than sorting through a collection of all messages, the developer can simply perform a fast query to find the channel related to the specified user.
     
     */
    class Channel {
        
        /**
         
         Creates a new channel with no existing messages.
         
         - Parameter users: Array of `String` that contains the unique identifiers of the all participants of the channel. `users.sorted()` serves as one of two unique identifiers for the channel.
         - Parameter named: Optional name of the channel. Default is `nil`.
         - Parameter author: The unique identifier of the creater of the channel.
         - Parameter completion: Escapes with `Error`.
         - Parameter error: Contains a message and the error type upon completion.
         
         */
        static func create(withUsersIDs users: [String], named: String? = nil, authorID author: String? = Auth.auth().currentUser?.uid ?? nil, _ completion: @escaping (_ error: Error) -> Void) {
            
            let ChannelCollection = Firestore.firestore().collection(String.Database.Channel.collectionID)
            let newChannelID: String = ChannelCollection.document().documentID
            
            log.debug("Creating new channel with ID \(newChannelID)...")
            
            /// Channel can only be created if there is a valid user
            guard let author = author else {
                completion(Error.error(type: .weak, text: "A channel cannot be created without an author."))
                return
            }
            
            /// Add the creator of the channel to the list of users
            var u = users
            if !u.contains(author) {
                u.append(author)
            }
             
            /// To find if there is a channel that contains a specific set of users,
            /// we must sort the array and save as a string.
            let sortedUsers = u.sorted()
            
            /// Check if the channel already exists
            doesChannelExist(withUsers: sortedUsers) { (exist, _, error) in
                
                /// Check if there is an error
                guard let exist = exist else {
                    completion(error)
                    return
                }
                
                /// Channel exists for the given set of users
                if exist {
                    completion(Error.error(type: .weak, text: error.text ?? "Channel already exists."))
                    return
                }
                
                /// Channel does not exist. Create new channel
                ChannelCollection.document(newChannelID).setData([
                     
                     /// Metadata about the channel
                     String.Database.Channel.id: newChannelID,                                   // Unique ID and document name of the channel being created
                     String.Database.Channel.author: author,                                     // Unique ID of the channel creater
                     String.Database.Channel.admin: [author],                                    // List of admin users that have control of the channel
                     String.Database.Channel.userString: "\(sortedUsers)",                       // Sorted list of users as a string
                     String.Database.Channel.users: sortedUsers,                                 // List of all users in the channel. Must be SORTED to uniquely identifY without channel ID
                     String.Database.Channel.created: NSDate().timeIntervalSince1970,            // Timestamp that the channel was created
                     
                     /// Data from last message sent in channel
                     String.Database.Channel.lastMedia: NSNull(),                                // Last message: Id of media sent. Null if no message
                     String.Database.Channel.lastSender: NSNull(),                               // Last message: User to send message. Null if no message
                     String.Database.Channel.lastText: NSNull(),                                 // Last message: Text of last message. Null if no message
                     String.Database.Channel.lastTimestamp: NSNull(),                            // Last message: Timestamp that last message was sent. Null if no message
                     String.Database.Channel.lastReplyTo: NSNull(),                              // Last message: User of last message. Null if message was to user in channel
                 
                 ], merge: true) { (error) in
                     
                     guard let error = error else {
                         completion(Error.error(type: .none, text: "Channel \(newChannelID) has been created successfully!"))
                         return
                     }
                     
                     completion(Error.error(type: .system, text: error.localizedDescription))
                     return
                 }
            }
        }
        
        
        /**
        
        Determines whether a channel exists for a given set of users.
         
        - Parameter users: Set of users for determining whether or not there is an existing channel
        - Parameter completion: Escapes with whether or not a channel exists, the channel ID, and `Error`
        - Parameter exists: True if a channel exists for the given set of users. Otherwise false. `nil` if there is an error.
        - Parameter channel: Metadata about the channel if one exists for a given set of users. Otherwise `nil`.
        - Parameter error: Contains a message and the error type upon completion.
         
         */
        static func doesChannelExist(withUsers users: [String], _ completion: @escaping (_ exist: Bool?, _ channel: BSChannel?, _ error: Error) -> Void) {
            Firestore.firestore().collection(String.Database.Channel.collectionID)
                .whereField(String.Database.Channel.userString, isEqualTo: "\(users.sorted())")
                .getDocuments { (snapshot, error) in
                    
                    /// Check for errors. If error, escape
                    if let error = error {
                        completion(nil, nil, Error.error(type: .system, text: error.localizedDescription))
                        return
                    }
                    
                    /// Check if snapshot exists. If not, escape
                    guard let snapshot = snapshot else {
                        completion(false, nil, Error.error(type: .weak, text: "Snapshot is empty or collection does not exist."))
                        return
                    }
                    
                    /// Result
                    if snapshot.documents.isEmpty {
                        
                        completion(false, nil, Error.error(type: .none, text: "There are no channels for this set of users."))
                        
                    } else {
                        
                        let data: [String: Any] = snapshot.documents[0].data()
                        
                        /// Saves the channel data to be escaped
                        let channel: BSChannel = BSChannel()
                        channel.channelID = snapshot.documents[0].documentID
                        channel.admin = data[String.Database.Channel.admin] as? [String] ?? nil
                        channel.author = data[String.Database.Channel.author] as? String ?? nil
                        channel.created = data[String.Database.Channel.created] as? Double ?? nil
                        channel.lastMedia = data[String.Database.Channel.lastMedia] as? String ?? nil
                        channel.lastReplyTo = data[String.Database.Channel.lastReplyTo] as? String ?? nil
                        channel.lastSender = data[String.Database.Channel.lastSender] as? String ?? nil
                        channel.lastText = data[String.Database.Channel.lastText] as? String ?? nil
                        channel.lastTimestamp = data[String.Database.Channel.lastTimestamp] as? Double ?? nil
                        channel.users = data[String.Database.Channel.users] as? [String] ?? nil
                        
                        completion(true, channel, Error.error(type: .none, text: "A channel exists for the set of users."))
                        
                    }
            }
        }
        
    } /* Channel - END */
    
} /* BSMessaging - END */
