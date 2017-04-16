//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/13/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {
    
@IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
    var image: UIImage!
    var name: String!
    var screenName: String!
    var tweetText: String!
    var tweet: Tweet!
    var retweetResponse: Tweet!
    var favoriteResponse: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(tweet)
        profileImageView.setImageWith(tweet?.profileUrl as! URL)
        nameLabel.text = tweet.name
        sreenNameLabel.text = tweet.screenName
        tweetTextLabel.text = tweet.text
        retweetLabel.text = "\(tweet.retweetCount) RETWEETS"
        likesLabel.text = "\(tweet.favouritesCount) LIKES"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onRetweetButton(_ sender: Any) {
        let tweetID = tweet.tweetID
        let params = ["id": tweetID!] as [String : Any]

        TwitterClient.sharedInstance.retweet(params: params as NSDictionary?,
            success: { (tweet: Tweet) in
            self.retweetResponse = tweet
            self.retweetLabel.text = "\(self.retweetResponse.retweetCount) RETWEETS"
        }, failure: { (error: Error?) in
            print(error?.localizedDescription as Any)
        })
    }
    
    @IBAction func onFavoriteButton(_ sender: Any) {
        let tweetID = tweet.tweetID
        let params = ["id": tweetID!] as [String : Any]
        
        TwitterClient.sharedInstance.favorite(params: params as NSDictionary?,
            success: { (tweet: Tweet) in
            self.favoriteResponse = tweet
            self.likesLabel.text = "\(self.favoriteResponse.favouritesCount) LIKES"
        }, failure: { (error: Error?) in
            print(error?.localizedDescription as Any)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue for tweet reply to pass tweet ID.
        if(segue.identifier == "TweetReply") {
            let navVC = segue.destination as? UINavigationController
            let ComposeVC = navVC?.viewControllers.first as! ComposeViewController
            ComposeVC.tweet = tweet
        }
    }
}
