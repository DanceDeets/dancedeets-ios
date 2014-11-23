//
//  ViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class FaceBookLoginViewController: UIViewController, FBLoginViewDelegate {
    
    let facebookPermission:[String] = ["public_profile", "email", "user_friends","rsvp_event","user_events"]

    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var mainLoginTitle: MainAppLabel!
    
    @IBOutlet weak var danceDeetsTitleView: MainAppLabel!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = facebookPermission
        
        view.backgroundColor = UIColor.blackColor()
    }

    // MARK: FBLoginViewDelegate
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
       println("loginViewShowingLoggedInUser")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        println("loginViewFetchedUserInfo")
        
        AppDelegate.sharedInstance().fbGraphUserObjectId = user.objectID
        
        println("Facebook fetched Graph User Info")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        println("User Email: \(userEmail)")
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}

