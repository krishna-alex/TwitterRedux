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
                profilePicImageView.setImageWith(_tweet?.profileUrl as! URL)
                timestampLabel.text = _tweet?.getTimeElapsedSinceCreatedAt()
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

        // Configure the view for the selected state
    }

}

