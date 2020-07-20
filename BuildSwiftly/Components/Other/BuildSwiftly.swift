//
//  BuildSwiftly.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import Foundation
import Firebase

class BuildSwiftly {
    
    static func configure() {
        FirebaseApp.configure()
        
        /// Initialize Push Notifications
        let pushNotifications = BSPushNotification()
        pushNotifications.register() /// Test. This may not work.
    }
    
}
