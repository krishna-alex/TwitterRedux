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
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "ATNFELmn5qe3oi2ICK6B9P7je", consumerSecret:
        "jecNfFYWd0oH7XYRq4yVeVdeoRCTmswsi1CRlgP4Wyo0iz1ecs")!
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) -> Void in
            let token = requestToken?.token
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token!)")!
            //print(url)
            UIApplication.shared.open(url)
            
        }) { (error: Error?) -> Void in
            print("error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        }
    }
    
    func handleUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) -> Void in
            
            self.loginSuccess?()
            /*currentAccount()
            homeTimeLine(success: { (tweets: [Tweet]) in
                for tweet in tweets {
                    print(tweet.text)
                }
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })*/
            
        }) { (error: Error?) -> Void in
            print("Error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        }
    }
    
    func currentAccount() {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
            print("account: \(response)")
            let userDictionary = response as! NSDictionary
            
            let user = User(dictionary: userDictionary)
            print("name: \(user.name)")
            print("scrrenname: \(user.screenName)")
            print("profileurl: \(user.profileUrl)")
            print("description: \(user.tagline)")
            
            }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
        })
        
    }
    
    func homeTimeLine(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
        }, failure: { (task:URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }

}
