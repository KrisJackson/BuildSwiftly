//
//  ViewController.swift
//  BuildSwiftly
//
//  Created by Kristopher Jackson.
//  Copyright © 2020 Kristopher Jackson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func testSendMessage() {
        var media: [Media] = []
        let images: [UIImage?] = [UIImage(named: "image1.jpg"), UIImage(named: "image2.jpg"), UIImage(named: "image3.jpg")]
        for image in images {
            var m =  Media()
            m.data = image?.jpegData(compressionQuality: 1.0)
            m.ext = "jpg"
            media.append(m)
        }
        
        /// Prepare message to be sent
        var message = Message()
        message.channelID = "abc"
        message.media = media
        message.replyToUID = "kris"
        message.senderUID = "kasd"
        message.text = "Test message"
        message.users = ["asdfa", "asfasd"]
        
        let messaging = BSMessaging.MessageHandler(message: message)
        messaging.send { (error) in
            print("🟢 " + (error.text ?? "No error message"))
        }
    }


}

