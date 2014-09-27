//
//  ViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class FaceBookLoginViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var mainLoginTitle: MainAppLabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var danceDeetsTitleView: MainAppLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions =  ["public_profile", "email", "user_friends"]
        
        view.backgroundColor = UIColor.blackColor()
        let subtitleFont = UIFont(name:"BebasNeueRegular",size: 30)
        self.subTitleLabel.font = subtitleFont
    }

    // MARK: FBLogingViewDelegate
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
       println("User Logged In")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
         appDelegate.facebookGraphUser = user
        
        println("Facebook fetched Graph User Info")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        println("User Email: \(userEmail)")
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.facebookGraphUser = nil
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.facebookGraphUser = nil
    }

}

