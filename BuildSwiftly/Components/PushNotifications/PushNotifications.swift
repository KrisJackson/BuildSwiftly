//
//  PushNotifications.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import UIKit
import FirebaseMessaging

class BSPushNotification: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {

    /**
     
     Initializes and configures push notifications.
     
     This function should be called in `AppDelegate.application(didFinishLaunchingWithOptions: )`.
     
     */
    func register() {
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
    }

    
    /**
     
     Sends push notification from the current device to another specified device.
     
     - Parameter title: The title of the push notification
     - Parameter message: The body of the push notification
     - Parameter token: The unique token of the receiving device
     
     - Firebase Cloud Messaging API Key is required for this to work as expected.
     - Push Notifications will not work with the simulator, so test with real devices.
     
     */
    static func send(title: String?, message: String?, toDeviceWithToken token: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = [
            "to" : token,
            "notification" : [
                "title" : title ?? nil,
                "body" : message ?? nil,
                "sound": "default"
            ],
            "data" : [
                "user" : "test_id"
            ]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(FCM_SERVER_KEY)", forHTTPHeaderField: "Authorization") /// Provide SERVER_KEY in Secrets.swift as a Global variable

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /// FIRMessaging uses method swizzling to ensure that the APNS token is set automatically.
        /// If swizzling is disabled, this manually sets the deviceToken
//        Messaging.messaging().apnsToken = deviceToken
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        /// For remote notifications, this property contains the entire notification payload.
        /// For local notifications, you configure the property directly before scheduling the notification.
        Logging.log(type: .info, text: response.notification.request.content.userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        /// Escapes with notification presentation options
        /// For notifications, allow alerts, badge on app icon, and sound
        completionHandler([.alert, .badge, .sound])
    }

}
