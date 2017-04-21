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
        
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let tweetsTable = userTweetsTableView!
        let favTable = userTweetsTableView!
        self.scrollView.addSubview(tweetsTable)
        self.scrollView.addSubview(favTable)
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 4, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        
        //set the current page and set the tweets to load as user tweets
        self.pageControl.currentPage = 0
        tweetType = "Tweets"
        
        //Load the user info and tweets.
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        print("In scrollViewDidEndDecelerating")
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        // Change the content accordingly
        if Int(currentPage) == 0{
            tweetType = "Tweets"
        }else if Int(currentPage) == 1{
            tweetType = "Favourites"
        }
        print("tweetType", tweetType)
        getUserTweets()
        userTweetsTableView.reloadData()
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
