//
//  PushNotifications.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import UIKit
import FirebaseMessaging

/**
 
 Class handles functionality and logic behind sending Push Notifications between two devices.
 
 A common use case might be when a user sends a direct message to another user. This component will be called when notifying the recipient.
 
 */
class PushNotification: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {

    /// Firebase Cloud Messaging unique identifier of the current device.
    ///
    /// Needed to send Push Notifications. Recommend storing in database.
    let deviceToken = Messaging.messaging().fcmToken
    

    /**
     
     Function initializes and configures settings for Push Notification.
     
     This is intended to be called in App Delegate.
     
     */
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            // Allow alert, badge, and sound
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
            
        } else {
            
            // Allow alert, badge, and sound
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            
        }
        UIApplication.shared.registerForRemoteNotifications()
        log.debug("Push notification registered!")
    }
    
    
    /**
     
     Handles sending of Push Notification from one device to another.
     
     - Parameter header: Optional `String` that sits at the top of the Push Notification view. This may be used to reference the sender in a direct message.
     - Parameter body: Optional `String` that sits below the title in the Push Notification view. This may be used to reference the the sender's message in a direct message.
     - Parameter token: The unique token of the receiving device
     
     */
    static func send(header: String?, body: String?, toDeviceWithToken token: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        
        // Body or header can be empty, but not both
        if ((body ?? nil) == nil) && ((header ?? nil) == nil) {
            log.warning("Message not sent! Title and message cannot both be empty.")
            return
        }
        
        let paramString: [String : Any] = [
            "to" : token,
            "notification" : [
                "title" : header ?? nil,
                "body" : body ?? nil,
                "sound": "default"
            ],
            "data" : [
                "user" : "test_id"
            ]
        ]

        // HTTP Request
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(FCM_API_KEY)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        log.debug("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                log.warning(err.debugDescription)
            }
        }
        task.resume()
    }


}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log.debug(response.notification.request.content.userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
}
