//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/19/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,ComposeViewControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileScreenNameLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var userTweetsTableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var profileUIView: UIView!
    
    var user: User!
    var tweets: [Tweet]!
    var lastTweetId: Int? = nil
    private var composeNavigationController: UIViewController!
    private var composeSegueIdentifier: String!
    private var tweetScreenName: String?
    private var userScreenName: String?
    private var tweetType: String?
    var tweetUserData: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTweetsTableView.dataSource = self
        userTweetsTableView.delegate = self
        userTweetsTableView.estimatedRowHeight = 60
        userTweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.29, green: 0.73, blue: 0.93, alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        profileImage.layer.cornerRadius = 3
        profileImage.clipsToBounds = true
        
        //Load the user info and tweets.
        getUserInfo()
        
        self.scrollView.isPagingEnabled = true
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 2, height:self.scrollView.frame.height)
        self.scrollView.showsHorizontalScrollIndicator  = false
        
        loadScrollView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    
    func getUserInfo() {
        if let screenName = tweetUserData {
            userScreenName = screenName
        } else {
            userScreenName = User.currentUser?.screenName
            self.navigationItem.leftBarButtonItem = nil
        }
    
        TwitterClient.sharedInstance.getUserByScreenname(screenname: userScreenName! as NSString, success: { (user: User) in
            self.user = user
            self.profileNameLabel.text = user.name
            self.profileScreenNameLabel.text = "@" + user.screenName!
            self.profileImage.setImageWith(user.profileUrl! as URL)
            self.profileBackgroundImage.setImageWith(user.backgroundImageUrl! as URL)
            self.followersCountLabel.text = "\(user.followersCount ?? 0)"
            self.followingCountLabel.text = "\(user.followingCount ?? 0)"
            self.getUserTweets()
            //self.loadScrollView()
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    func getUserTweets() {
        if tweetType == "Tweets" {
            TwitterClient.sharedInstance.user_timeline(user: user, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.userTweetsTableView.reloadData()
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
        } else {
            let screenName = user.screenName!
            TwitterClient.sharedInstance.getFavourites(screenName: screenName, success: { (tweets:[Tweet]) in
                self.tweets = tweets
                self.userTweetsTableView.reloadData()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        }
    }
    
    func loadScrollView() {
        let tweetsTable = userTweetsTableView!
        let favTable = userTweetsTableView!
        self.scrollView.addSubview(tweetsTable)
        self.scrollView.addSubview(favTable)
        self.scrollView.delegate = self
        
        //set the current page and set the tweets to load as user tweets
        self.pageControl.currentPage = 0
        tweetType = "Tweets"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ userTweetsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tweets != nil) {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ userTweetsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweetCell = userTweetsTableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        let resultTweet:Tweet
        resultTweet = tweets[indexPath.row]
        cell.singleTweet = resultTweet
        animate(cell: cell)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Calculate the current page after scrolling ends
        // Change the indicator
        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
        self.pageControl.currentPage = Int(currentPage)
        userTweetsTableView.frame.size.width = self.view.bounds.size.width
        userTweetsTableView.frame.origin.x = currentPage * self.view.bounds.size.width
        // Change the content accordingly
        if Int(currentPage) == 0{
            tweetType = "Tweets"
        }else if Int(currentPage) == 1{
            tweetType = "Favourites"
        }
        getUserTweets()
        userTweetsTableView.reloadData()
    }
    
    func animate(cell: TweetCell) {
        let view = cell.contentView
        view.layer.opacity = 0.1
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction, .transitionCurlUp], animations: { () -> Void in
            view.layer.opacity = 1
        }, completion: nil)
    }
    
    @IBAction func onComposeButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        composeNavigationController = storyboard.instantiateViewController(withIdentifier: "ComposeNavigationController")
        composeSegueIdentifier = "composeSegue"
        self.present(composeNavigationController, animated:true, completion:nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if(composeSegueIdentifier == "composeSegue") {
//            let navigationController = segue.destination as! UINavigationController
//            let composeViewController = navigationController.topViewController as! ComposeViewController
//            composeViewController.delegate = self
//        }
//    }
}
