//
//  User.swift
//  Twitter
//
//  Created by Krishna Alex on 4/11/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name: String?
    var screenName: String?
    var profileUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary?

    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        tagline = dictionary["description"] as? String
    }
    
    static var userDidLogoutNotification = "UserDidLogout"
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? Data
                if let userData = userData {
                    let dictionary = try? JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    if let dictionary = dictionary {
                        _currentUser = User(dictionary: (dictionary))
                    }
                }
            }
            
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])

                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.set(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
}

