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

 A message contains data that is sent by one user to another user or group of users. Each message belongs to a channel, and each channel is a way to identify individual chats.
 
*/
struct Message {
    
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
    var timestamp: Int!
    
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

class MessageHandler {
    /**
     
        Sends a message to all users within the channel. Messages can contain either text, media, or both. When a message is sent
 
    */
    static func send(message: Message, _ completion: @escaping (_ error: Error) -> Void) {
        
        log.debug("Preparing to send message...")
        
        let MessageRef = Firestore.firestore().collection(String.Database.Messaging.collectionID).document()
        let MessageID = MessageRef.documentID
        
        /* *** Check for errors  *** */
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
        
        /// Media and text cannot both be empty
        if (message.text ?? nil) == nil && (message.mediaID ?? nil) == nil {
            completion(Error.error(type: .weak, text: "No message has been given."))
            return
        }
        
        /// Trim down extra whitespace and check if text is empty
        if let text = message.text {
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (message.mediaID ?? nil) == nil {
                completion(Error.error(type: .weak, text: "No message has been given."))
                return
            }
        }/* *** Check for errors -- END *** */
        
        
        /// Prepare data to be sent!
        var messageBuf = message
        messageBuf.users = users
        messageBuf.senderUID = sender
        messageBuf.messageID = MessageID
        
        
        /// Checks if media exists. If so, store media first, then send message.
        if var batchMedia = messageBuf.media {
            
            
            /// Names each media file in the batch and saves in buffer
            messageBuf.mediaID = []
            for (i, _) in batchMedia.enumerated() {
                let mediaID = "\(MessageID)-\(i)"
                batchMedia[i].name = mediaID
                messageBuf.mediaID.append(mediaID)
            }
            
            
            /// Upload media to Firebase Storage
            /// If media is successfully stored, send message to Firestore.
            Batch.upload(media: batchMedia, atPath: Storage.storage().reference(withPath: "\(String.Database.Messaging.collectionID)/")) { (error) in
                switch error.type {
                case .none:
                    
                    /// Media successfully stored! Send message!
                    self.sendMessage(messageBuf, toRef: MessageRef) { (error) in
                        completion(error)
                        return
                    }
                    
                default:
                    
                    completion(error)
                    return
                    
                }
            }
            
        } else {
            
            /// No media to send. Send text message.
            self.sendMessage(messageBuf, toRef: MessageRef) { (error) in
                completion(error)
            }
            
        }
        
    }
    
    
    private static  func sendMessage(_ message: Message, toRef MessageRef: DocumentReference, _ completion: @escaping (_ error: Error) -> Void) {
        MessageRef.setData([
            
            String.Database.Messaging.users: message.users.sorted(),
            String.Database.Messaging.text: message.text ?? NSNull(),
            String.Database.Messaging.media: message.mediaID ?? NSNull(),
            String.Database.Messaging.sender: message.senderUID ?? NSNull(),
            String.Database.Messaging.replyTo: message.replyToUID ?? NSNull(),
            String.Database.Messaging.channelID: message.channelID ?? NSNull(),
            String.Database.Messaging.messageID: message.messageID ?? NSNull(),
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
}
