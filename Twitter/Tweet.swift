//
//  Tweet.swift
//  Twitter
//
//  Created by Krishna Alex on 4/11/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var tweetID: Int?
    var text: String?
    var createdAt: Date?
    var retweetCount: Int = 0
    var favouritesCount: Int = 0
    var screenName: String?
    var profileUrl: NSURL?
    var name: String?
    var retweeted: Bool?
    
    init(dictionary: NSDictionary) {
        if let retweet = dictionary["retweeted_status"] as? NSDictionary {
            retweeted = true
            tweetID = retweet["id"] as? Int
            text = retweet["text"] as? String
            retweetCount = (retweet["retweet_count"] as? Int) ?? 0
            favouritesCount = (retweet["favorite_count"] as? Int) ?? 0
            
            let createdAtString = retweet["created_at"] as? String
            if let createdAtString = createdAtString {
                let formatter = DateFormatter()
                //sample created_at value - Tue Aug 28 21:16:23 +0000 2012
                formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
                createdAt = formatter.date(from: createdAtString)
            }
            if let user = retweet["user"] as? NSDictionary {
                screenName = user["screen_name"] as? String
                name = user["name"] as? String
                let profileUrlString = user["profile_image_url_https"] as? String
                if let profileUrlString = profileUrlString {
                    profileUrl = NSURL(string: profileUrlString)
                }
            }
        } else {
            retweeted = false
        tweetID = dictionary["id"] as? Int
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favouritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        let createdAtString = dictionary["created_at"] as? String
        if let createdAtString = createdAtString {
            let formatter = DateFormatter()
            //sample created_at value - Tue Aug 28 21:16:23 +0000 2012
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = formatter.date(from: createdAtString)
        }
        if let user = dictionary["user"] as? NSDictionary {
            screenName = user["screen_name"] as? String
            name = user["name"] as? String
            let profileUrlString = user["profile_image_url_https"] as? String
            if let profileUrlString = profileUrlString {
                profileUrl = NSURL(string: profileUrlString)
            }
        }
        }
    }
        
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets
    }
    
    func getTimeElapsedSinceCreatedAt() -> String {
        let interval = Float(self.createdAt!.timeIntervalSinceNow)
        let second: Float = 1.0, minute: Float = second*60, hour: Float = minute*60, day: Float = hour*24
        var num: Float = abs(interval), unit = "day", retVal = "now"
        
        if (interval == 0) {
            return retVal
        }
        
        if (num >= day) {
            num /= day;
            if (num > 1) {
                unit = "d"
            }
        }
        else if (num >= hour) {
            num /= hour;
            unit = "h"
        }
        else if (num >= minute) {
            num /= minute;
            unit = "m";
        }
        else if (num >= second) {
            num /= second;
            unit = "s";
        }
        
        return "\(Int(num))\(unit)"
    }
    
    class func getDateFormatterObject() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale!
        dateFormatter.dateFormat = "eee, MMM dd"
        
        return dateFormatter;
    }
}

