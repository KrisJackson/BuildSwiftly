//
//  Messaging.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Firebase
import FirebaseFirestore
import Foundation

/**
 
 In-app messaging component that facilitates the exchange of data and text sent between users.
 
 - There are many uses for a messaging component within an app. In-app messaging allows users to communicate and send data to each other over the network. To effectively allow users to communicate between one another, this component is organized into two main
 sub-components: `Sender` and `Channel`. A channel can be thought of as a 'chat room'. Each `Channel` contains metadata about the chat room that can be easily and quickly accessed. The `Sender` contains functions that pertains to an individual message to be sent in the channel.
 - This component assumes that the client is using Firebase Auth, Firebase Storage, and Cloud Firestore, and has already set up those tools as needed.
 - Messaging component allows both direct messages and group messages
 - Sending a message requires the channel ID. If the channel ID is not known, use `BSMessaging.Channels.doesExist(users: [String])`
 
 */
class BSMessaging {
    
    /**
     
     Contains functions that pertains to an individual message to be sent in the channel
     
     */
    class Sender {
        
        private var error: Error!
        private var messageBuf: BSMessage!
        private var messageRef: DocumentReference!
        
        
        /**
            Constructor prepares message to be sent and checks that message contains values for required fields.
         
            - Parameter message: Message that a user intends to send within a channel. `Message.messageID`, `Message.timestamp`, and `Message.mediaID` is assigned by the API, so client should pass `nil` or leave fields empty when passing through `Sender`.
         
         */
        init(message: BSMessage) {
            
            messageBuf = message
            messageRef = Firestore.firestore().collection(String.Database.Messaging.collectionID).document()
            messageBuf.messageID = messageRef.documentID
            
            guard message.channelID != nil else {
                error = Error.error(type: .weak, text: "Message point to a channel.")
                return
            }
            
            /// Checks that `Message` has a sender
            guard message.senderUID != nil else {
                error = Error.error(type: .weak, text: "Message must contain a sender.")
                return
            }
            
            /// Checks that `Message` has recipient array and at least one recipient
            if let users = message.users {
                
                /// Checks that the recipient array contains at least one user
                if users.isEmpty {
                    error = Error.error(type: .weak, text: "Message must contain at least one recipient.")
                    return
                }
                
            } else {
                
                /// Recipient array does not exist
                error = Error.error(type: .weak, text: "Message must contain at least one recipient.")
                return
                
            }
            
            /// Checks that `Message` has either some media or some text, but the message must contain something to sent
            if let text = message.text {
                
                let trimText = text.trimmingCharacters(in: .whitespacesAndNewlines) // Remove extra whitespace
                if trimText.isEmpty && (message.mediaID ?? nil) == nil {
                    error = Error.error(type: .weak, text: "No message has been given.")
                    return
                }
                
            } else {
                
                /// Media and text cannot both be empty
                if (message.mediaID ?? nil) == nil {
                    error = Error.error(type: .weak, text: "No message has been given.")
                    return
                }
                
            }
            
        }
        
        
        /**
         
            Sends a message to the channel.
            - Parameter completion: Escapes with `Error`.
            - Parameter error: Contains error type (`ErrorType.none` if no errors) and message that can be displayed in the UI if needed.
     
        */
        func send(_ completion: @escaping (_ error: Error) -> Void) {
            
            log.debug("Preparing to send message...")
            
            /// Checks for errors
            if let error = error {
                completion(Error.error(type: error.type, text: error.text))
                return
            }
            
            /// Send `Message` to Firestore
            /// If the message contains media, send media first then text (if there is text)
            if var batchMedia = messageBuf.media {
                
                /// Names each media file in the batch and saves in buffer
                messageBuf.mediaID = []
                for (i, _) in batchMedia.enumerated() {
                    let mediaID = "\(messageBuf.messageID!)-\(i)"
                    batchMedia[i].name = mediaID
                    messageBuf.mediaID.append(mediaID)
                }
                
                /// Upload media to Firebase Storage
                /// If media is successfully stored, send message to Firestore.
                Batch.upload(media: batchMedia, atPath: Storage.storage().reference(withPath: "\(String.Database.Messaging.collectionID)/")) { (error) in
                    switch error.type {
                    case .none:
                        
                        /// Sends text if exists
                        if let _ = self.messageBuf.text {
                            /// Message contains text
                            self.sendMessage(toRef: self.messageRef) { (error) in
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
                self.sendMessage(toRef: messageRef) { (error) in
                    completion(error)
                }
                
            }
            
        }
        
        
        /**
         
         Updates the channel with the lastest message passed in `MessageHandler`.
         - Parameter completion: Escapes with `Error`
         - Parameter error: Contains error type (`ErrorType.none` if no errors) and message that can be displayed in the UI if needed.
         
         */
        func updateChannel(_ completion: @escaping (Error) -> Void) {
            
            /// Reference to the channel being
            let channelRef = Firestore.firestore()
                .collection(String.Database.Channel.collectionID)
                .document(messageBuf.channelID)
            
            channelRef.setData([
            
                String.Database.Channel.lastText: messageBuf.text ?? NSNull(),
                String.Database.Channel.lastMedia: messageBuf.mediaID ?? NSNull(),
                String.Database.Channel.lastSender: messageBuf.senderUID ?? NSNull(),
                String.Database.Channel.lastReplyTo: messageBuf.replyToUID ?? NSNull(),
                String.Database.Channel.lastTimestamp: messageBuf.timestamp ?? NSDate().timeIntervalSince1970,
            
            ], merge: true) { (error) in
                
                if let error = error {
                    completion(Error.error(type: .system, text: error.localizedDescription))
                } else {
                    completion(Error.error(type: .none, text: "Channel has been updated!"))
                }
                
            }
        }
        
        
        /**
         
         PRIVATE: Extracts data from `Message` and sends data to Firestore.
         - Parameter toRef: Documents reference of the message in Firestore. Message reference is created when `MessageHandler` is initialized and populated in this function.
         - Parameter completion: Escapes with `Error`.
         - Parameter error: Contains error type (`ErrorType.none` if no errors) and message that can be displayed in the UI if needed.
         
         */
        private func sendMessage(toRef messageRef: DocumentReference, _ completion: @escaping (_ error: Error) -> Void) {
            
            /// Set the time sent
            let timestamp = NSDate().timeIntervalSince1970
            messageBuf.timestamp = timestamp
            
            let sortedUsers = messageBuf.users.sorted()
            
            /// Send data to Firestore
            messageRef.setData([
    
                String.Database.Messaging.users: sortedUsers,   /// **Must be sorted**. Sorted users serves as another way to uniquely identify channel if client doesn't know Channel ID
                String.Database.Messaging.userString: "\(sortedUsers)",
                String.Database.Messaging.text: messageBuf.text ?? NSNull(),
                String.Database.Messaging.media: messageBuf.mediaID ?? NSNull(),
                String.Database.Messaging.sender: messageBuf.senderUID ?? NSNull(),
                String.Database.Messaging.replyTo: messageBuf.replyToUID ?? NSNull(),
                String.Database.Messaging.channelID: messageBuf.channelID ?? NSNull(),
                String.Database.Messaging.messageID: messageBuf.messageID ?? NSNull(),
                String.Database.Messaging.timestamp: messageBuf.timestamp ?? NSDate().timeIntervalSince1970,
            
            ], merge: true) { (error) in
                
                if let error = error {
                    
                    completion(Error.error(type: .system, text: error.localizedDescription))
                    
                } else {
                    
                    completion(Error.error(type: .none, text: "Message has successfully been sent!"))
                    
                    /// Update channel w latest message
                    self.updateChannel { (error) in
                        /// ** Can do something here, but not necessary **
                    }
                    
                }
                
            }
        }
        
        
        
    } /* Sender - END */
    
} /* BSMessaging - END */