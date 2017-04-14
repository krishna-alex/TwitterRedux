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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReplyButton(_ sender: Any) {
        
        
    }
    
    @IBAction func onRetweetButton(_ sender: Any) {
        let tweetID = tweet.tweetID
        let params = ["id": tweetID] as [String : Any]

        TwitterClient.sharedInstance.retweet(params: params as NSDictionary?,
            success: { (tweet: Tweet) in
            self.retweetResponse = tweet
            self.retweetLabel.text = "\(self.retweetResponse.retweetCount) RETWEETS"
        }, failure: { (error: Error?) in
            print("retweet failed")
            print(error?.localizedDescription)
        })
    }
    
    @IBAction func onFavoriteButton(_ sender: Any) {
        let tweetID = tweet.tweetID
        let params = ["id": tweetID] as [String : Any]
        
        TwitterClient.sharedInstance.favorite(params: params as NSDictionary?,
            success: { (tweet: Tweet) in
            self.favoriteResponse = tweet
            self.likesLabel.text = "\(self.favoriteResponse.favouritesCount) LIKES"
        }, failure: { (error: Error?) in
            print("Favorite failed")
            print(error?.localizedDescription)
        })

    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue for tweet reply to pass tweet ID.
        if(segue.identifier == "TweetReply") {
            let navVC = segue.destination as? UINavigationController
            let ComposeVC = navVC?.viewControllers.first as! ComposeViewController
            ComposeVC.tweet = tweet
        }
    }

}
