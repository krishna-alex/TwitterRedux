//
//  TweetCell.swift
//  Twitter
//
//  Created by Krishna Alex on 4/12/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    
    let tapRecognizer1: UITapGestureRecognizer = UITapGestureRecognizer()
    
    private var _tweet: Tweet?
    
    var singleTweet: Tweet {
        get {
            return self._tweet!
        }
        set(singleTweet) {
            self._tweet = singleTweet
            if (self._tweet != nil) {
                tweetTextLabel?.text = _tweet?.text
                nameLabel?.text = _tweet?.name
                screenNameLabel.text = "@" + (_tweet?.screenName)!
                //Load image off main thread.
                profilePicImageView.imageFromServerURL(urlString: (_tweet?.profileUrl)!)
                timestampLabel.text = _tweet?.getTimeElapsedSinceCreatedAt()
                retweetLabel.text = ""
                if(_tweet?.retweeted == true) {
                    retweetLabel.text = "Retweeted"
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicImageView.layer.cornerRadius = 3
        profilePicImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: NSURL) {
        
        URLSession.shared.dataTask(with: urlString as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error as Any)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

