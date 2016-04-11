//
//  LoadingViewController.swift
//  DanceDeets
//
//  Created by LambertMike on 2016/04/06.
//  Copyright © 2016年 DanceDeets. All rights reserved.
//

import Foundation

class LoadingViewController : UIViewController {

    var refreshLoops: Int = 0

    var openingEventId: String?
    var openingEvent: Event?
    var loggedIn: Bool = false

    // MARK: The usual
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidAppear(animated: Bool) {
        CLSNSLogv("%@", getVaList(["viewDidAppear"]))

        if let eventId = AppDelegate.sharedInstance().openingEventId {
            openingEventId = eventId
            ServerInterface.getEvent(eventId, completion: loadedEventData)
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoadingViewController.observeTokenChange), name: FBSDKAccessTokenDidChangeNotification, object: nil)
            observeTokenChange()
        }
    }

    func loadedEventData(event: Event?, error: NSError?) {
        if event != nil {
            openingEvent = event
            maybeShowEvent()
        }
    }

    func maybeShowEvent() {
        CLSNSLogv("%@", getVaList(["maybeShowEvent"]))
        if let event = openingEvent where loggedIn {
            CLSNSLogv("%@", getVaList(["logged in, showing event \(event.id)"]))
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let navVC = sb.instantiateViewControllerWithIdentifier("mainNavVC")
            let eventListVC = sb.instantiateViewControllerWithIdentifier("EventListView")
            let eventInfoVC = sb.instantiateViewControllerWithIdentifier("eventInfoViewController")
            if let vc = eventInfoVC as? EventInfoViewController {
                vc.events = [event]
                vc.startEvent = event
            }
            if let nc = navVC as? UINavigationController {
                nc.pushViewController(eventInfoVC, animated: true)
                let stackCount = nc.viewControllers.count
                let addIndex = stackCount - 1
                nc.viewControllers.insert(eventListVC, atIndex: addIndex)
            }
            presentViewController(navVC, animated: false, completion: nil)
        }
    }


    func showReal() {
        loggedIn = true
        if openingEventId != nil {
            maybeShowEvent()
        } else {
            showList()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? EventInfoViewController {
            if let event = openingEvent {
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        CLSNSLogv("%@", getVaList(["viewWillDisappear"]))
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FBSDKAccessTokenDidChangeNotification, object: nil)
    }


    func observeTokenChange() {
        let token = FBSDKAccessToken.currentAccessToken()

        CLSNSLogv("observeTokenChange, token is %@", getVaList([token != nil ? token : "nil"]))
        // No token, send them to the tutorial
        if token == nil {
            waitForClickToShowTutorial();
        } else {
            let now = NSDate()
            let age = now.timeIntervalSinceDate(token.refreshDate)
            CLSNSLogv("Refresh Date: %@, Now Date: %@, Date Diff in Seconds: %f", getVaList([token.refreshDate, now, age]))
            if (age < 60 * 60) {
                // Recent token, let's just send them on their way now
                showReal()
            } else if (!token.hasGranted("user_events")) {
                // TODO: If the user cancels-out, this can create problems when we come back through this same code path
                // It results in the following error when we call this twice:
                // The SFSafariViewController's parent view controller was dismissed.
                // This can happen if you are triggering login from a UIAlertController. Instead, make sure your top most view controller will not be prematurely dismissed.
                loginOnly()
            } else {
                CLSNSLogv("%@", getVaList(["Medium age cached token, refreshing token to find current status"]))
                if (refreshLoops > 0) {
                    // Let's just go here regardless, so we avoid an infinite loop of refreshing
                    // Not sure if this happens in real life, but don't want to risk it
                    CLSNSLogv("%@", getVaList(["Found a refresh loop, shouldn't happen! Sending to the ListView..."]))
                    showReal()
                } else {
                    // Otherwise attempt to refresh the token, and act based on that
                    FBSDKAccessToken.refreshCurrentAccessToken(onRefreshTokenResult)
                    refreshLoops += 1
                }
            }
        }
    }

    func onRefreshTokenResult(connect:FBSDKGraphRequestConnection!, obj: AnyObject!, error: NSError!) {
        CLSNSLogv("%@", getVaList(["onRefreshTokenResult"]))
        if (error != nil) {
            CLSNSLogv("onRefreshTokenResult Error: %@", getVaList([error]))
            loginOnly()
        }
        // Any valid tokens will be handled in observeTokenChange()
    }

    func onLoginFinished(result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void {
        CLSNSLogv("%@", getVaList(["onLoginFinished"]))
        if error != nil {
            CLSNSLogv("onLoginFinished Error: %@", getVaList([error]))
            AnalyticsUtil.track("Login - Error Code", ["Code": String(error.code)])
        }
        if (error == nil && result.token != nil) {
            CLSNSLogv("onLoginFinished Result: %@", getVaList([result]))
            AnalyticsUtil.track("Login - Completed")
            // We don't handle this here, instead handling it through the natural observeTokenChange notification
            // after this view is properly loaded again
            //observeTokenChange()
        }
    }

    func loginOnly() {
        CLSNSLogv("%@", getVaList(["loginOnly, asking for permissions"]))
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email", "user_friends", "user_events"], fromViewController:self, handler: self.onLoginFinished);
    }

    func waitForClickToShowTutorial() {
        CLSNSLogv("%@", getVaList(["waitForClickToShowTutorial"]))

        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(showTutorial))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
    }

    func showTutorial() {
        CLSNSLogv("%@", getVaList(["showTutorial"]))
        performSegueWithIdentifier("showTutorial", sender: self)
    }

    func showList() {
        CLSNSLogv("%@", getVaList(["showList"]))
        AnalyticsUtil.login()
        ServerInterface.sharedInstance.updateFacebookToken()
        #if DEBUG
            //TODO: this only happens on the second time, after we've already logged in
            //TODO: clean this up, do it as part of a proper device flow (after user logs in, not before!)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        #endif
        performSegueWithIdentifier("showList", sender: self)
    }
}