//
//  MyCitiesViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    let TOOLS_SECTION:Int = 0
    
    var backgroundBlurView:UIView?
    
    // MARK: Outlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Action
    @IBAction func doneButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UIViewController    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = ColorFactory.tableSeparatorColor()
        tableView.allowsSelectionDuringEditing = true
        tableView.allowsMultipleSelection = false

        title = NSLocalizedString("SETTINGS", comment: "Page Title")

        var titleOptions = [String:AnyObject]()
        titleOptions[NSFontAttributeName] = FontFactory.navigationTitleFont()
        navigationController?.navigationBar.titleTextAttributes = titleOptions
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == TOOLS_SECTION) {
            return 3
        } else {
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == TOOLS_SECTION) {
            let header = UILabel(frame: CGRectZero)
            header.text = NSLocalizedString("TOOLS", comment: "Settings List Header")
            header.textAlignment = NSTextAlignment.Center
            header.font = FontFactory.settingsHeaderFont()
            header.textColor = ColorFactory.white50()
            return header
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == TOOLS_SECTION) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCellWithIdentifier("sendFeedbackCell", forIndexPath: indexPath)
                return cell
            } else if(indexPath.row == 1) {
                let cell = tableView.dequeueReusableCellWithIdentifier("addEventCell", forIndexPath: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == TOOLS_SECTION) {
            if (indexPath.row == 0) {
                if MFMailComposeViewController.canSendMail() {
                    let composer = MFMailComposeViewController()
                    let recipients:[String] = ["feedback@dancedeets.com"]
                    composer.mailComposeDelegate = self
                    composer.setSubject("DanceDeets Feedback")
                    composer.setToRecipients(recipients)
                    presentViewController(composer, animated: true, completion: nil)
                } else {
                    let alertView = UIAlertView(title: NSLocalizedString("Cannot send feedback", comment: "Error Title"), message: NSLocalizedString("You cannot send feedback through email, because you have no email accounts set up on this iPhone/iPad.", comment: "Error Description"), delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
            } else if (indexPath.row == 1) {
                AnalyticsUtil.track("Add Event")
                let token = FBSDKAccessToken.currentAccessToken()
                let url = NSURLComponents(string: "http://www.dancedeets.com/events_add")!
                url.queryItems = [
                    NSURLQueryItem(name: "uid", value: token.userID),
                    NSURLQueryItem(name: "access_token", value: token.tokenString),
                ]
                let realUrl = url.URL!
                let row = tableView.cellForRowAtIndexPath(indexPath) as? SettingsCell

                let webViewController = WebViewController()
                webViewController.configure(withUrl: realUrl, andTitle: row?.label?.text ?? "")
                navigationController!.pushViewController(webViewController, animated: true)
            } else if (indexPath.row == 2) {
                AnalyticsUtil.logout()
                FBSDKAccessToken.setCurrentAccessToken(nil)
                FBSDKProfile.setCurrentProfile(nil)
                performSegueWithIdentifier("postLogout", sender: self)
            }
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
