//
//  ViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class FaceBookLoginViewController: UIViewController, FBLoginViewDelegate, UITextViewDelegate{
    
    @IBOutlet weak var fbLoginView: FBLoginView!
    @IBOutlet weak var disclaimerTextView: UITextView!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = FaceBookLoginViewController.getDefaultFacebookPermissions
        view.backgroundColor = UIColor.blackColor()
        
        // set up disclaimer text
        var terms = NSMutableAttributedString(string: "here")
        terms.addAttribute(NSLinkAttributeName, value: NSURL(string: "http://www.dancedeets.com")!, range: NSMakeRange(0, terms.length))
        terms.setColor(ColorFactory.lightBlue())
        
        var first = NSMutableAttributedString(string: "You may still access Dance Deets ")
        first.setColor(UIColor.blackColor())
        
        var last = NSMutableAttributedString(string: " if you do not want to log in.")
        last.setColor(UIColor.blackColor())
        
        var disclaimerString = NSMutableAttributedString(string: "")
        disclaimerString.appendAttributedString(first)
        disclaimerString.appendAttributedString(terms)
        disclaimerString.appendAttributedString(last)
        
        var centeredStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        centeredStyle.alignment = NSTextAlignment.Center
        disclaimerString.addAttribute(NSParagraphStyleAttributeName, value: centeredStyle, range: NSMakeRange(0, disclaimerString.length))
        disclaimerString.setFont(FontFactory.disclaimerFont())
        
        disclaimerTextView.attributedText = disclaimerString
        disclaimerTextView.textContainerInset = UIEdgeInsetsZero
        disclaimerTextView.delegate = self
        
    }
    
    class var getDefaultFacebookPermissions : [String]{
        return ["public_profile", "email", "user_friends"]
    }
    
    // MARK: FBLoginViewDelegate
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("loginViewShowingLoggedInUser")
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        // update token on back
        ServerInterface.sharedInstance.updateFacebookToken()
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        println("loginViewFetchedUserInfo")
        
        AppDelegate.sharedInstance().fbGraphUserObjectId = user.objectID
        
        println("Facebook fetched Graph User Info")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as! String
        println("User Email: \(userEmail)")

        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        // update token on back
        ServerInterface.sharedInstance.updateFacebookToken()
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }

}

