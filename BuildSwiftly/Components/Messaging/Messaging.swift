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
 
 In-app messaging component that facilitates the exchange of data and text sent between user.
 
 - There are many uses for a messaging component within an app. In-app messaging allows users to communicate and send data to each other over the network. To effectively allow users to communicate between one another, this component is organized into two main
 sub-components: `Sender` and `Channel`. A channel can be thought of as a 'chat room'. Each `Channel` contains metadata about the chat room that can be easily and quickly accessed. The `Sender` contains functions that pertains an individual that wishes to send a message in the channel.
 - This component assumes that the client is using Firebase Auth, Firebase Storage, and Cloud Firestore, and has already set up those tools as needed.
 - Messaging component allows both direct messages and group messages
 
 */
class BSMessaging {
    
    /**
     
     Contains functions for users that wishes to send a message in a specific channel.
     
     */
    class Sender {
        
        /**
         
            Sends a message to all users within the channel. Messages can contain either text, media, or both. When a message is sent
     
        */
        static func send(message: Message, _ completion: @escaping (_ error: Error) -> Void) {
            
            log.debug("Preparing to send message...")
            
            let messageRef = Firestore.firestore().collection(String.Database.Messaging.collectionID).document()
            let messageID = messageRef.documentID
            
            /// Checks that `Message` has a sender
            guard let sender = message.senderUID else {
                completion(Error.error(type: .weak, text: "Message must contain a sender."))
                return
            }
            
            /// Checks that `Message` has recipient array and at least one recipient
            let users = message.users
            if let users = users {
                
                /// Checks that the recipient array contains at least one user
                if users.isEmpty {
                    completion(Error.error(type: .weak, text: "Message must contain at least one recipient."))
                    return
                }
                
            } else {
                
                /// Recipient array does not exist
                completion(Error.error(type: .weak, text: "Message must contain at least one recipient."))
                return
                
            }
            
            /// Checks that `Message` has either some media or some text, but the message must contain something to sent
            if let text = message.text {
                
                let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines) // Remove extra whitespace
                if trimText.isEmpty && (message.mediaID ?? nil) == nil {
                    completion(Error.error(type: .weak, text: "No message has been given."))
                    return
                }
                
            } else {
                
                /// Media and text cannot both be empty
                if (message.mediaID ?? nil) == nil {
                    completion(Error.error(type: .weak, text: "No message has been given."))
                    return
                }
                
            }
            
            /// Prepare `Message` to be sent
            var messageBuf = message
            messageBuf.users = users!
            messageBuf.senderUID = sender
            messageBuf.messageID = messageID
            
            
            /// Send `Message` to Firestore
            /// If the message contains media, send media first then text (if there is text)
            
            if var batchMedia = messageBuf.media {
                
                /// Names each media file in the batch and saves in buffer
                messageBuf.mediaID = []
                for (i, _) in batchMedia.enumerated() {
                    let mediaID = "\(messageID)-\(i)"
                    batchMedia[i].name = mediaID
                    messageBuf.mediaID.append(mediaID)
                }
                
                /// Upload media to Firebase Storage
                /// If media is successfully stored, send message to Firestore.
                Batch.upload(media: batchMedia, atPath: Storage.storage().reference(withPath: "\(String.Database.Messaging.collectionID)/")) { (error) in
                    switch error.type {
                    case .none:
                        
                        /// Sends text if exists
                        if let _ = messageBuf.text {
                            /// Message contains text
                            self.sendMessage(messageBuf, toRef: messageRef) { (error) in
                                completion(error)
                                return
                            }
                        } else {
                            /// Message does not contain text
                            completion(error)
                            return
                        }
                        
                    default:
                        
                        /// Batch upload did not success. Terminate and complete with error
                        completion(error)
                        return
                        
                    }
                }
                
            } else {
                
                /// No media to send. Send text message.
                self.sendMessage(messageBuf, toRef: messageRef) { (error) in
                    completion(error)
                }
                
            }
            
        }
        
        
        /**
         
            PRIVATE: Extracts data from `Message` and sends data to Firestore.
         
         */
        private static func sendMessage(_ message: Message, toRef MessageRef: DocumentReference, _ completion: @escaping (_ error: Error) -> Void) {
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
}
