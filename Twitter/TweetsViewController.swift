//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/11/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tweetsTableView: UITableView!

    var tweets: [Tweet]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetsTableView.dataSource = self
        tweetsTableView.delegate = self
        tweetsTableView.estimatedRowHeight = 60
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        
        //Set Navigation bar color
        //navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.11, green: 0.63, blue: 0.95, alpha: 1.0)
        //navigationController?.navigationBar.barStyle = UIBarStyle.black
        
        navigationItem.titleView = UIImageView.init(image: UIImage(named:"Twitter-icon1.png"))
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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
    
    func getTweets() {
        TwitterClient.sharedInstance.homeTimeLine(success: { (tweets: [Tweet]) in
            self.tweets = tweets
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
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
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


