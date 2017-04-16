//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/13/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

@objc protocol ComposeViewControllerDelegate {
    @objc optional func ComposeViewController(ComposeViewController: ComposeViewController, didTweet tweet: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    
    var user: User!
    var tweet: Tweet!
    var tweetID: Int = 0
    var replyTweet: Bool = false
    weak var delegate: ComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.delegate = self
        tweetTextView.text = "What's happening?"
        tweetTextView.textColor = .lightGray
        
        //Check for reply or new tweet
        if let tweet = tweet {
            replyTweet = true
            tweetID = tweet.tweetID!
            tweetTextView.text = "@" + tweet.screenName! + " "
            tweetTextView.textColor = .black
        }
        tweetTextView.becomeFirstResponder()
        
        TwitterClient.sharedInstance.currentAccount(success: { (user: User) in
            self.user = user
            self.userNameLabel.text = user.name
            self.screenNameLabel.text = "@" + user.screenName!
            self.profileImageView.setImageWith(user.profileUrl as! URL)
        }) { (error: Error) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ tweetTextView: UITextView)
    {
        if replyTweet == false {
            tweetTextView.text = ""
            tweetTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ tweetTextView: UITextView)
    {
        if (tweetTextView.text == "")
        {
            tweetTextView.text = "What's happening?"
            tweetTextView.textColor = .lightGray
        }
        tweetTextView.resignFirstResponder()
    }
    
    
    @IBAction func onTweetButton(_ sender: Any) {
        let tweetMessage = tweetTextView.text
        
        TwitterClient.sharedInstance.tweet(message: tweetMessage!, tweetID: tweetID, success: { (Tweet) in
            print("I tweeted")
            self.delegate?.ComposeViewController?(ComposeViewController: self, didTweet: Tweet)
            self.dismiss(animated: true, completion: nil)
        }) { (error: Error) in
            print("tweet error")
            print(error.localizedDescription)
        }
    }
    
    func textViewDidChange(_ tweetTextView: UITextView) {
        let charCount = tweetTextView.text.characters.count
        characterCountLabel.text = String(140 - charCount)
        
        switch charCount {
        case Int.min...0:
            tweetButton.isEnabled = false
            break
        case 1...140:
            tweetButton.isEnabled = true
            break
        case 141...Int.max:
            tweetButton.isEnabled = false
            break
        default:
            break
        }
    }
}
