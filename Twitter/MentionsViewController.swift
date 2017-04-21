//
//  MentionsViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/19/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class MentionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ComposeViewControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet]!
    var lastTweetId: Int? = nil
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    private var composeNavigationController: UIViewController!
    private var composeSegueIdentifier: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.29, green: 0.73, blue: 0.93, alpha: 1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.black
        
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        //get tweets from home timeline
        getTweets()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterClient.sharedInstance.logout()
    }
    
    func getTweets() {
        if (tweets) != nil {
            //Since maxId value is inclusive, subtract 1 from the lowest Tweet ID returned from the previous request and use this for the value of max_id
            lastTweetId = tweets[tweets.endIndex - 1].tweetID! - 1 as Int
        }
        
        TwitterClient.sharedInstance.mentions(success: { (tweets:[Tweet]) in
            self.isMoreDataLoading = false
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            if (self.tweets) != nil {
                self.tweets.append(contentsOf: tweets)
            } else {
                self.tweets = tweets
            }
            
            self.tableView.reloadData()
        }) { (error: Error) in
            print(error.localizedDescription)
        }
       
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tweets != nil) {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweetCell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        let resultTweet:Tweet
        resultTweet = tweets[indexPath.row]
        cell.singleTweet = resultTweet
        return cell
    }
    
   
    @IBAction func onComposeButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        composeNavigationController = storyboard.instantiateViewController(withIdentifier: "ComposeNavigationController")
        composeSegueIdentifier = "composeSegue"
        self.present(composeNavigationController, animated:true, completion:nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(composeSegueIdentifier == "composeSegue") {
            let navigationController = segue.destination as! UINavigationController
            let composeViewController = navigationController.topViewController as! ComposeViewController
            composeViewController.delegate = self
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
