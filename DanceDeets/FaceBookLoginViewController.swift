//
//  ViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FaceBookLoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextViewDelegate{
    @IBOutlet weak var fbLoginView: FBSDKLoginButton!
    @IBOutlet weak var disclaimerTextView: UITextView!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = FaceBookLoginViewController.getDefaultFacebookPermissions
        view.backgroundColor = UIColor.blackColor()

        AnalyticsUtil.track("Login - Not Logged In")

        // set up disclaimer text
        let terms = NSMutableAttributedString(string: "here")
        //TODO: track clicks on this with AnalyticsUtil.track("Login - Use Website")
        terms.addAttribute(NSLinkAttributeName, value: NSURL(string: "http://www.dancedeets.com")!, range: NSMakeRange(0, terms.length))
        terms.setColor(ColorFactory.lightBlue())
        
        let first = NSMutableAttributedString(string: "You may still access DanceDeets ")
        first.setColor(UIColor.blackColor())
        
        let last = NSMutableAttributedString(string: " if you do not want to log in.")
        last.setColor(UIColor.blackColor())
        
        let disclaimerString = NSMutableAttributedString(string: "")
        disclaimerString.appendAttributedString(first)
        disclaimerString.appendAttributedString(terms)
        disclaimerString.appendAttributedString(last)
        
        let centeredStyle:NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        centeredStyle.alignment = NSTextAlignment.Center
        disclaimerString.addAttribute(NSParagraphStyleAttributeName, value: centeredStyle, range: NSMakeRange(0, disclaimerString.length))
        disclaimerString.setFont(FontFactory.disclaimerFont())
        
        disclaimerTextView.attributedText = disclaimerString
        disclaimerTextView.textContainerInset = UIEdgeInsetsZero
        disclaimerTextView.delegate = self
        
    }
    
    class var getDefaultFacebookPermissions : [String]{
        return ["public_profile", "email", "user_friends", "user_events"]
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        if (result.token != nil) {
            AnalyticsUtil.track("Login - Completed")
        } else {
            AnalyticsUtil.track("Login - Not Logged In")
        }
        // update token on back
        ServerInterface.sharedInstance.updateFacebookToken()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("logged out")
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }

}

