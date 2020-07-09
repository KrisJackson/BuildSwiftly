//
//  Messaging.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

/**

 Stores message data sent between devices.
 
*/
struct Message {
    var messageID: String!
    var channelID: String!
    var text: String!
    var timestamp: Int!
    var users: [String]!
    var media: [Any]!
    var mediaID: [String]!
    var senderUID: String!
    var replyToUID: String? = nil
}

class MessageHandler {
    
    func send(message: Message, _ completion: @escaping(Error) -> Void) {
        
        log.debug("Preparing to send message...")
        
        let MessageRef = Firestore.firestore().collection(String.Database.Messaging.collectionID).document()
        let MessageID = MessageRef.documentID
        
        guard let sender = message.senderUID else {
            completion(Error.error(type: .weak, text: "Message must contain a sender."))
            return
        }
        
        guard let users = message.users else {
            completion(Error.error(type: .weak, text: "Message must contain at least one recipient."))
            return
        }
        
        if users.isEmpty {
            completion(Error.error(type: .weak, text: "Message must contain at least one recipient."))
            return
        }
        
        // Media and text cannot both be empty
        if (message.text ?? nil) == nil && (message.mediaID ?? nil) == nil {
            completion(Error.error(type: .weak, text: "No message has been given."))
            return
        }
        
        // Trim down extra whitespace and check if text is empty
        if let text = message.text {
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (message.mediaID ?? nil) == nil {
                completion(Error.error(type: .weak, text: "No message has been given."))
                return
            }
        }
        
        if let _ = message.messageID { log.info("No need to include \'messageID\'. We assign it for you!") }
        if let _ = message.timestamp { log.info("No need to include \'timestamp\'. We record it for you!") }
        
        
        
        // MARK: - Create function that sends media to storage if media exists
        
        
        
        MessageRef.setData([
            
            String.Database.Messaging.sender: sender,
            String.Database.Messaging.messageID: MessageID,
            String.Database.Messaging.users: users.sorted(),
            String.Database.Messaging.text: message.text ?? NSNull(),
            String.Database.Messaging.media: message.mediaID ?? NSNull(),
            String.Database.Messaging.replyTo: message.replyToUID ?? NSNull(),
            String.Database.Messaging.channelID: message.channelID ?? NSNull(),
            String.Database.Messaging.timestamp: NSDate().timeIntervalSince1970,
        
        ], merge: true) { (error) in
            
            if let error = error {
                completion(Error.error(type: .system, text: error.localizedDescription))
                return
            }
            
            completion(Error.error(type: .none, text: "Message has successfully been sent!"))
            return
            
        }
        
    }
    
    private func store(media: Data, _ completion: @escaping (Error) -> Void) {
        
        Storage.storage().reference(withPath: "\(String.Database.Messaging.collectionID)/")
        
    }
}
