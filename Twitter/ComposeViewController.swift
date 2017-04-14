//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/13/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var userImageButton: UIBarButtonItem!
    
    
    var user: User!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.delegate = self
        tweetTextView.text = "What's happening?"
        tweetTextView.textColor = .lightGray
        
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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ tweetTextView: UITextView)
    {
            tweetTextView.text = ""
            tweetTextView.textColor = .black

        tweetTextView.becomeFirstResponder() //Optional
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
        
        TwitterClient.sharedInstance.tweet(message: tweetMessage!, success: { (Tweet) in
            print("I tweeted")
            self.dismiss(animated: true, completion: nil)
        }) { (error: Error) in
            print("tweet error")
            print(error.localizedDescription)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
