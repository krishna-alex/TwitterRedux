//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/11/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate {
    
    @IBOutlet weak var tweetsTableView: UITableView!
    var tweets: [Tweet]!
    var lastTweetId: Int? = nil
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        tweetsTableView.estimatedRowHeight = 60
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.titleView = UIImageView.init(image: UIImage(named:"Twitter-icon1.png"))
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tweetsTableView.addSubview(loadingMoreView!)
        
        var insets = tweetsTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tweetsTableView.contentInset = insets
        
        //get tweets from home timeline
        getTweets()
        
        //Pull to refresh tweets
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tweetsTableView.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
    
    func getTweets() {
        if (tweets) != nil {
                //Since maxId value is inclusive, subtract 1 from the lowest Tweet ID returned from the previous request and use this for the value of max_id
                lastTweetId = tweets[tweets.endIndex - 1].tweetID! - 1 as Int
        }
        
        TwitterClient.sharedInstance.homeTimeLine(maxId: lastTweetId, success: { (tweets: [Tweet]) in
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            if (self.tweets) != nil {
                self.tweets.append(contentsOf: tweets)
            } else {
                self.tweets = tweets
            }
            
            self.tweetsTableView.reloadData()
            }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tweetsTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tweets != nil) {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tweetsTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweetCell = tweetsTableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        let resultTweet:Tweet
        resultTweet = tweets[indexPath.row]
        cell.singleTweet = resultTweet
        
        return cell
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        getTweets()
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tweetsTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height, width: tweetsTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Load more results
                getTweets()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "TweetDetailView") {
            let destinationViewController = segue.destination as! TweetDetailViewController
            if let indexPath = tweetsTableView.indexPathForSelectedRow {
                let cell = tweetsTableView.cellForRow(at: indexPath) as! TweetCell
                let indexPath = tweetsTableView.indexPath(for: cell)
                let tweet = tweets[(indexPath?.row)!]
                destinationViewController.tweet = tweet
            }
        }
        if(segue.identifier == "TweetComposeView") {
            let navigationController = segue.destination as! UINavigationController
            let composeViewController = navigationController.topViewController as! ComposeViewController
            composeViewController.delegate = self
        }
    }
    
    func ComposeViewController(ComposeViewController: ComposeViewController, didTweet tweet: Tweet) {
        self.tweets.insert(tweet, at: 0)
        tweetsTableView.reloadData()
    }
}

