//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/19/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ComposeViewControllerDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileScreenNameLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    var user: User!
    private var composeNavigationController: UIViewController!
    private var composeSegueIdentifier: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.29, green: 0.73, blue: 0.93, alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        profileImage.layer.cornerRadius = 3
        profileImage.clipsToBounds = true
        
        TwitterClient.sharedInstance.currentAccount(success: { (user: User) in
            self.user = user
            self.profileNameLabel.text = user.name
            self.profileScreenNameLabel.text = "@" + user.screenName!
            self.profileImage.setImageWith(user.profileUrl as! URL)
            self.profileBackgroundImage.setImageWith(user.backgroundImageUrl as! URL)
            self.followersCountLabel.text = "\(user.followersCount ?? 0)"
            self.followingCountLabel.text = "\(user.followingCount ?? 0)"
        }) { (error: Error) in
            print(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
    
    @IBAction func onComposeButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        composeNavigationController = storyboard.instantiateViewController(withIdentifier: "ComposeNavigationController")
        composeSegueIdentifier = "composeSegue"
        self.present(composeNavigationController, animated:true, completion:nil)
        
//        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as LoginViewController
//        self.navigationController?.pushViewController(secondViewController, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(composeSegueIdentifier == "composeSegue") {
            let navigationController = segue.destination as! UINavigationController
            let composeViewController = navigationController.topViewController as! ComposeViewController
            composeViewController.delegate = self
        }
    }
    
//    func ComposeViewController(ComposeViewController: ComposeViewController, didTweet tweet: Tweet) {
//        self.tweets.insert(tweet, at: 0)
//        tweetsTableView.reloadData()
//    }
//    

}
