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
    
    var user: User!
    var tweets: [Tweet]!
    var lastTweetId: Int? = nil
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    private var composeNavigationController: UIViewController!
    private var composeSegueIdentifier: String!
    private var tweetScreenName: String?
    private var userScreenName: String?
//    var tweetUserData: String?
    
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
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: userTweetsTableView.contentSize.height, width: userTweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        userTweetsTableView.addSubview(loadingMoreView!)
        
        var insets = userTweetsTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        userTweetsTableView.contentInset = insets
        
        getUserInfo()
        
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
        }
    
        TwitterClient.sharedInstance.getUserByScreenname(screenname: userScreenName as! NSString, success: { (user: User) in
            self.user = user
            self.profileNameLabel.text = user.name
            self.profileScreenNameLabel.text = "@" + user.screenName!
            self.profileImage.setImageWith(user.profileUrl as! URL)
            self.profileBackgroundImage.setImageWith(user.backgroundImageUrl as! URL)
            self.followersCountLabel.text = "\(user.followersCount ?? 0)"
            self.followingCountLabel.text = "\(user.followingCount ?? 0)"
            self.getUserTweets()
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }
    
    func getUserTweets() {
        if (tweets) != nil {
            //Since maxId value is inclusive, subtract 1 from the lowest Tweet ID returned from the previous request and use this for the value of max_id
            lastTweetId = tweets[tweets.endIndex - 1].tweetID! - 1 as Int
        }
        TwitterClient.sharedInstance.user_timeline(user: user, maxId: lastTweetId, success: { (tweets: [Tweet]) in
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            if (self.tweets) != nil {
                self.tweets.append(contentsOf: tweets)
            } else {
                self.tweets = tweets
            }
            
            self.userTweetsTableView.reloadData()
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
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
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = userTweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - userTweetsTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && userTweetsTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: userTweetsTableView.contentSize.height, width: userTweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Load more results
                getUserTweets()
            }
        }
    }
    
    @IBAction func onComposeButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        composeNavigationController = storyboard.instantiateViewController(withIdentifier: "ComposeNavigationController")
        composeSegueIdentifier = "composeSegue"
        self.present(composeNavigationController, animated:true, completion:nil)
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
