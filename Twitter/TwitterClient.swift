//
//  TwitterClient.swift
//  Twitter
//
//  Created by Krishna Alex on 4/11/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "ANFSbP7fZkEwUfZ32S9K38ih8", consumerSecret:
        "QyuhCGKJL9LvZZakOJWjRNYLnmQlwV8Id0x1sNPC3fNtwtPQ7U")!
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) -> Void in
            let token = requestToken?.token
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token!)")!
            UIApplication.shared.open(url)
            
        }) { (error: Error?) -> Void in
            self.loginFailure?(error!)
        }
    }
    
    func logout() {
        User.currentUser = nil //set the current user to nil before loggingout
        deauthorize()
        
        // post a notification "UserDidLogout" to cleanup the user related data - like clear the tweets from table view.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    func handleUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) -> Void in
            
            self.currentAccount(success: { (user: User) in
                User.currentUser = user // set the current user, saves in NSDefaults to persist user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
        }) { (error: Error?) -> Void in
            print("Error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        }
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
                failure(error)
        })
    }
    
    func getUserByScreenname(screenname: NSString, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/users/lookup.json?screen_name=" + String(screenname), parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let userDictionary = response as! [NSDictionary]
            let user = User(dictionary: userDictionary[0])
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func homeTimeLine(maxId: Int? = nil, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var params = ["count": 20]
        if maxId != nil {
            params["max_id"] = maxId
        }
        
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            success(tweets)
        }, failure: { (task:URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func user_timeline(user: User, maxId: Int? = nil, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var params = ["count": 20]
        params["user_id"] = user.id!
        if maxId != nil {
            params["max_id"] = maxId
        }
        
        get("1.1/statuses/user_timeline.json", parameters: params, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func tweet(message: String, tweetID: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let params = ["status": message, "in_reply_to_status_id": tweetID] as [String : Any]
        print("tried to tweet", params)
        post("1.1/statuses/update.json", parameters: params, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("failure ocurred", error)
            failure(error)
        })
    }
    
    func mentions(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        //let params = ["status": message, "in_reply_to_status_id": tweetID] as [String : Any]
        //print("tried to tweet", params)
        get("1.1/statuses/mentions_timeline.json", parameters: nil, progress: nil,
             success: { (task: URLSessionDataTask, response: Any?) in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
                success(tweets)

        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("failure ocurred", error)
            failure(error)
        })
    }
    
    func getFavourites(screenName: String, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        let params = ["screen_name": screenName] as [String : Any]
        //print("tried to tweet", params)
        get("1.1/favorites/list.json", parameters: params, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) in
                let dictionaries = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
                success(tweets)
                
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            print("failure ocurred", error)
            failure(error)
        })
    }
    
    func retweet(params: NSDictionary?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let tweetID = params!["id"] as! Int
        post("1.1/statuses/retweet/\(tweetID).json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error:Error) in
            failure(error)
        })
    }
    
    func populateTweetByID(params: NSDictionary?, success: @escaping (Tweet) -> (), failure: @escaping (Error?) -> ()) {
        let tweetID = params!["id"] as! Int
        get("1.1/statuses/show.json?id=\(tweetID)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        }) { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        }
    }
    
    func favorite(params: NSDictionary?, success: @escaping (Tweet) -> (), failure: @escaping (Error?) -> ()) {
        post("1.1/favorites/create.json", parameters: params, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error:Error) in
            failure(error)
        })
    }
}
