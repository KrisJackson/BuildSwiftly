//
//  Message.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson on 7/11/20.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation

/**

 Struct contains data that is being within the channel and data to direct the message to the correct channel.
 
*/
struct BSMessage {
    
    /// The unique identifier of the message document.
    var messageID: String!
    
    /// The unique identifier of the channel that the message belongs to.
    var channelID: String!
    
    /// The string of text that is being sent in the channel.
    ///
    ///
    /// Can be `nil` if the message contain some form of media.
    var text: String!
    
    /// The time that the message was sent.
    ///
    ///
    /// The time is recorded in unix time format.
    var timestamp: Double!
    
    /// Array of users within the channel.
    ///
    ///
    /// Sorting the `users` is another way to uniquely identify a channel.
    var users: [String]!
    
    /// Any batch of data that is not text being sent in the channel.
    ///
    ///
    /// All media is stored in Firebase Storage.
    var media: [Media]!
    
    /// Unique identifier of the media being stored in Firebase Storage.
    var mediaID: [String]!
    
    /// The unique identifier of the user sending the message.
    var senderUID: String!
    
    /// Unique identifer of the user that message was intended for.
    var replyToUID: String? = nil
    
}
