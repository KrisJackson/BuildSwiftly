//
//  Channel.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson 
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

/**
 
 The purpose of a channel is to store any important metadata related to a specific DM or a group chat. Each message should point directly to an existing channel.
 
 One common usage of channels may be when configuring an Inbox for your app. Rather than sorting through a collection of all messages, the developer can simply perform a fast query to find the channel related to the specified user.
 
 */
class Channel {
    
    /**
     
     Function called when creating a new channel.
     
     - Parameter users: Array of `String` that contains the unique identifiers of the all participants of the channel. `users.sorted()` serves as one of two unique identifiers for the channel.
     - Parameter named: Optional name of the channel. Default is `nil`.
     - Parameter author: The unique identifier of the creater of the channel.
     - Parameter completion: Escapes with `Error`.
     - Parameter error: Contains a message and the error type upon completion.
     
     */
    func create(withUsersIDs users: [String], named: String? = nil, authorID author: String? = Auth.auth().currentUser?.uid ?? nil, _ completion: @escaping(_ error: Error) -> Void) {
        
        let ChannelCollection = Firestore.firestore().collection(String.Database.Channel.collectionID)
        let newChannelID: String = ChannelCollection.document().documentID
        
        log.debug("Creating new channel with ID \(newChannelID)...")
        
        guard let author = author else {
            completion(Error.error(type: .weak, text: "A channel cannot be created without an author."))
            return
        }
        
        if users.isEmpty {
            completion(Error.error(type: .weak, text: "A channel must contain at least one user."))
            return
        }
        
        ChannelCollection.document(newChannelID).setData([
            
            String.Database.Channel.id: newChannelID,                                 // Unique ID and document name of the channel being created
            String.Database.Channel.author: author,                                   // Unique ID of the channel creater
            String.Database.Channel.admin: [author],                                  // List of admin users that have control of the channel
            String.Database.Channel.users: users.sorted(),                            // List of all users in the channel. Must be SORTED to uniquely identifY without channel ID
            String.Database.Channel.created: NSDate().timeIntervalSince1970,          // Timestamp that the channel was created
            
            String.Database.Channel.lastMedia: NSNull(),                              // Last message: Media sent. Null if no message
            String.Database.Channel.lastSender: NSNull(),                             // Last message: User to send message. Null if no message
            String.Database.Channel.lastText: NSNull(),                               // Last message: Text of last message. Null if no message
            String.Database.Channel.lastTimestamp: NSNull(),                          // Last message: Timestamp that last message was sent. Null if no message
            String.Database.Channel.lastReplyTo: NSNull(),                            // Last message: User of last message. Null if message was to user in channel
        
        ], merge: true) { (error) in
            
            guard let error = error else {
                completion(Error.error(type: .none, text: "Channel \(newChannelID) has been created successfully!"))
                return
            }
            
            completion(Error.error(type: .system, text: error.localizedDescription))
            return
        }
        
    }
    
    func exists(withUsers users: [String], _ completion: @escaping(Bool, Error) -> Void) {
        
    }
    
    func get(forUser user: String, _ completion: @escaping(Error) -> Void) {
        
    }
    
}
