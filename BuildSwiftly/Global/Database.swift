//
//  Database.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation

extension String {
    
    class Database {
        
        struct Messaging {
            
            static let collectionID = "messages"
            static let messageID = "messageID"
            static let channelID = "channelID"
            static let text = "text"
            static let timestamp = "timestamp"
            static let users = "users"
            static let media = "mediaIDs"
            static let sender = "senderUID"
            static let replyTo = "replyToUID"
            
        }
        
        struct Channel {
            
            static let collectionID = "channels"
            static let id = "id"
            static let author = "author"
            static let admin = "admin"
            static let users = "users"
            static let created = "created"
            static let lastMedia = "lastMedia"
            static let lastSender = "lastSender"
            static let lastText = "lastText"
            static let lastTimestamp = "lastTimestamp"
            static let lastReplyTo: String = "lastReplyTo"
        }
    }
}
