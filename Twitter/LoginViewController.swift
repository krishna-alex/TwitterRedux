//
//  LoginViewController.swift
//  Twitter
//
//  Created by Krishna Alex on 4/11/17.
//  Copyright © 2017 Krishna Alex. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func onLoginButton(_ sender: Any) {
        let twitterClient = BDBOAuth1SessionManager(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "ATNFELmn5qe3oi2ICK6B9P7je", consumerSecret:
            "jecNfFYWd0oH7XYRq4yVeVdeoRCTmswsi1CRlgP4Wyo0iz1ecs")!
        twitterClient.deauthorize()
        twitterClient.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) -> Void in
            print("I got a token")
            let token = requestToken?.token
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token!)")!
            //print(url)
            UIApplication.shared.open(url)
            
            }, failure: { (error: Error?) -> Void in
            print("error: \(error?.localizedDescription)")
            })
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
