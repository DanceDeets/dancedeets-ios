//
//  EventStreamViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 11/26/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI
import QuartzCore
import FBSDKCoreKit

class EventStreamViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    // MARK: Constants
    let CUSTOM_NAVIGATION_BAR_HEIGHT:CGFloat = 95.0
    let USER_SEARCH_LOCATION_KEY = "searchCity" // Magic key for storing a location in NSUserDefaults

    // MARK: Variables
    var locationFailureAlert:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
    var requiresRefresh = true
    var blurOverlay:UIView!
    var searchResultsTableViewBottomConstraint:NSLayoutConstraint?
    var titleTapGestureRecognizer:UITapGestureRecognizer?
    var currentGeooder:CurrentGeocode?

    var eventDisplay:EventDisplay?
    var searchBar:SearchBar?

    // MARK: Outlets
    @IBOutlet weak var eventListTableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var customNavigationView: UIView!
    @IBOutlet weak var customNavigationViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var locationSearchField: UITextField!
    @IBOutlet weak var keywordSearchField: UITextField!
    @IBOutlet weak var autosuggestTable: UITableView!
    @IBOutlet weak var searchTextCancelButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var textFieldsEqualWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationMaxWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var keywordMaxWidthConstraint: NSLayoutConstraint!
    // MARK: Action functions
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        refreshEvents()
    }

    @IBAction func settingsButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("settingsSegue", sender: sender)
    }
    
    func eventSelected(event: Event, eventImage: UIImage?) {
        // the collection cell of the selected event
        let destination = storyboard?.instantiateViewControllerWithIdentifier("eventDetailViewController") as! EventDetailViewController
        destination.initialImage = eventImage
        destination.event = event

        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        eventDisplay = EventDisplay(
            tableView: eventListTableView,
            heightOffset: CUSTOM_NAVIGATION_BAR_HEIGHT,
            andHandler: eventSelected)
        searchBar = SearchBar(controller: self, searchHandler: refreshEvents)

        view.layoutIfNeeded()
        
        loadViewController()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (requiresRefresh) {
            requiresRefresh = false
            currentGeooder = CurrentGeocode(completionHandler: geocodeCompletionHandler)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkFaceBookToken()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingsSegue" {
            let destination:SettingsViewController? = segue.destinationViewController as? SettingsViewController
            
            // take snap shot of our current view, add a blur, this is the background effect for the settings
            let snapShot:UIView = view.snapshotViewAfterScreenUpdates(false)
            let overlayView = UIVisualEffectView(effect: UIBlurEffect(style:UIBlurEffectStyle.Dark)) as UIVisualEffectView
            snapShot.addSubview(overlayView)
            overlayView.constrainToSuperViewEdges()
            destination?.view.insertSubview(snapShot, atIndex: 0)
            snapShot.constrainToSuperViewEdges()
            destination?.backgroundBlurView = snapShot
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func loadViewController() {
        // tapping on the title does a refresh
        titleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "refreshButtonTapped:")
        titleTapGestureRecognizer?.delegate = self
        navigationTitle.userInteractionEnabled = true
        navigationTitle.addGestureRecognizer(titleTapGestureRecognizer!)
        
        // custom navigation styling
        let customNavBlur = customNavigationView.addDarkBlurOverlay()
        customNavigationView.insertSubview(customNavBlur, atIndex: 0)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setTitle("", "")
        navigationItem.title = ""

        searchTextCancelButton.alpha = 0
    }

    func geocodeCompletionHandler(optionalPlacemark: CLPlacemark?) {
        if let placemark = optionalPlacemark {
            let fullText = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
            self.locationSearchField.text = fullText
            Event.loadEventsForLocation(self.locationSearchField.text!, withKeywords:self.keywordSearchField.text!, completion:self.setupEventsDisplay)
        } else {
            if let location = NSUserDefaults.standardUserDefaults().stringForKey(USER_SEARCH_LOCATION_KEY) {
                self.locationSearchField.text = location
            } else {
                setTitle("RETRY", "Couldn't get yo  ur location")
                locationFailureAlert.show()
            }
        }
    }

    func setTitle(mainTitle: String, _ secondaryTitle: String) {
        let separator = " "
        let attributedMainTitle = NSAttributedString(string: mainTitle + separator, attributes: [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName: FontFactory.navigationTitleFont()
        ])
        let attributedSecondaryTitle = NSAttributedString(string: secondaryTitle, attributes: [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName: FontFactory.eventDescriptionFont()
        ])
        let finalTitle = NSMutableAttributedString()
        finalTitle.appendAttributedString(attributedMainTitle)
        finalTitle.appendAttributedString(attributedSecondaryTitle)
        navigationTitle.attributedText = finalTitle
    }

    func setupEventsDisplay(events: [Event]!, error: NSError!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (error != nil) {
                let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                self.setTitle("ERROR", "Try again")
            } else if(events.count == 0) {
                let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Try expanding your search criteria?", delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.setTitle(self.locationSearchField.text!, "No Events")
            } else {
                self.setTitle(self.locationSearchField.text!, "\(self.keywordSearchField.text!) | \(events.count) Events")
            }
            self.eventDisplay!.setup(events, error: error)
        })
    }

    func refreshEvents(location: String, withKeywords keywords: String) {
        // If we do a search, store the location, in case we can't access GPS next time, we'll have a good cached value
        NSUserDefaults.standardUserDefaults().setObject(location, forKey: USER_SEARCH_LOCATION_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()

        self.setTitle(location, "Loading...")
        Event.loadEventsForLocation(location, withKeywords:keywords, completion: setupEventsDisplay)
    }

    func refreshEvents() {
        refreshEvents(locationSearchField.text!, withKeywords: keywordSearchField.text!)
    }
    
    func checkFaceBookToken() {
        let token = FBSDKAccessToken.currentAccessToken()
        if (token == nil) {
            self.navigationController?.performSegueWithIdentifier("presentFacebookLogin", sender: self)
        } else if (!token.hasGranted("user_events")) {
            // This user_events check is because for awhile we allowed iOS access without requesting this permission,
            // and now we wish these users to re-authorize with the additional permissions, even if they have a token.
            let login = FBSDKLoginManager()
            login.logInWithReadPermissions(["user_events"], fromViewController:self, handler: {  (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
                ServerInterface.sharedInstance.updateFacebookToken()
            });
        } else {
            AnalyticsUtil.login()
            FBSDKAccessToken.refreshCurrentAccessToken({ (connect:FBSDKGraphRequestConnection!, obj: AnyObject!, error: NSError!) -> Void in
                ServerInterface.sharedInstance.updateFacebookToken()
            })
        }
    }
    
}
