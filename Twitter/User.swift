//
//  User.swift
//  Twitter
//
//  Created by Krishna Alex on 4/11/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: Int?
    var name: String?
    var screenName: String?
    var profileUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary?
    var backgroundImageUrl: NSURL?
    var hasBannerImage = true
    
    var followersCount: Int?
    var followingCount: Int?
    
    var locationString: NSString?
    var protected: Bool?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        id = dictionary["id"] as? Int
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        let backgroundImageString = dictionary["profile_background_image_url_https"] as? String
        tagline = dictionary["description"] as? String
        if let backgroundImageString = backgroundImageString {
            backgroundImageUrl = NSURL(string: backgroundImageString)
        }
        //backgroundImageUrl = dictionary["profile_background_image_url_https"] as? String
//        if backgroundImageURL != nil {
//            backgroundImageURL?.append("/600x200")
//        } else {
//            backgroundImageURL = dictionary["profile_background_image_url_https"] as? String
//            hasBannerImage = false
//        }
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        
        locationString = dictionary["location"] as! NSString
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

