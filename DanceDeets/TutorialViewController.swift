//
//  TutorialViewController.swift
//  DanceDeets
//
//  Created by LambertMike on 2016/03/29.
//  Copyright © 2016年 david.xiang. All rights reserved.
//

import Foundation

class TutorialViewController : UIViewController {

    @IBOutlet weak var fbLoginButton: UIButton?

    @IBOutlet weak var websiteButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        fbLoginButton?.addTarget(self, action: #selector(loginButtonClicked), forControlEvents: .TouchUpInside)
        websiteButton?.addTarget(self, action: #selector(websiteButtonClicked), forControlEvents: .TouchUpInside)
    }

    func getDefaultFacebookPermissions() -> [String] {
        return ["public_profile", "email", "user_friends", "user_events"]
    }

    func loginResult(result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void {
        if error != nil {
            AnalyticsUtil.track("Login - Error Code", ["Code": String(error.code)])
        }
        if (error == nil && result.token != nil) {
            AnalyticsUtil.track("Login - Completed")
            performSegueWithIdentifier("postLogin", sender: self)

            //presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            // update token on back
            // AnalyticsUtil.login() ??
            ServerInterface.sharedInstance.updateFacebookToken()
        } else {
            AnalyticsUtil.track("Login - Not Logged In")
        }
    }

    func loginButtonClicked() {
        AnalyticsUtil.track("Login - FBLogin Button Pressed")
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(getDefaultFacebookPermissions(), fromViewController:self, handler: self.loginResult);
    }

    func websiteButtonClicked() {
        AnalyticsUtil.track("Login - Use Website")
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.dancedeets.com/")!)
    }
}