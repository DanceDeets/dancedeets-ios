//
//  EventStreamViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 11/26/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import CoreLocation
import FBSDKCoreKit
import GoogleMobileAds
import UIKit
import MessageUI
import QuartzCore

class EventStreamViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, GADBannerViewDelegate {
    
    // MARK: Constants
    let CUSTOM_NAVIGATION_BAR_HEIGHT:CGFloat = 95.0
    let USER_SEARCH_LOCATION_KEY = "searchCity" // Magic key for storing a location in NSUserDefaults

    // MARK: Variables
    var locationFailureAlert:UIAlertView = UIAlertView(
        title: NSLocalizedString("GPS Problem", comment: "Alert Title"),
        message: NSLocalizedString("Couldn't detect your location", comment: "GPS Failure"),
        delegate: nil,
        cancelButtonTitle: "OK")
    var blurOverlay:UIView!
    var searchResultsTableViewBottomConstraint:NSLayoutConstraint?
    var titleTapGestureRecognizer:UITapGestureRecognizer?
    var fetchAddress:FetchAddress?

    var eventDisplay:EventDisplay?
    var searchBar:SearchBar?
    var adBar:AdBar?

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

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bannerView: DFPBannerView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!

    // MARK: Action functions
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        refreshEvents()
    }

    @IBAction func settingsButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("settingsSegue", sender: sender)
    }
    
    func eventSelected(event: Event, eventImage: UIImage?) {
        // the collection cell of the selected event
        let destination = storyboard?.instantiateViewControllerWithIdentifier("eventInfoViewController") as! EventInfoViewController
        if let display = self.eventDisplay {
            destination.events = display.results?.events
            destination.startEvent = event
        }

        navigationController?.pushViewController(destination, animated: true)
    }

    func oneboxSelected(oneboxLink: OneboxLink) {
        AnalyticsUtil.track("Onebox", ["URL": oneboxLink.url!])
        let webViewController = WebViewController()
        webViewController.configure(withUrl: NSURL(string: oneboxLink.url!)!, andTitle: oneboxLink.title!)
        navigationController!.pushViewController(webViewController, animated: true)
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        eventDisplay = EventDisplay(
            tableView: eventListTableView,
            heightOffset: CUSTOM_NAVIGATION_BAR_HEIGHT,
            andEventHandler: eventSelected,
            andOneboxHandler: oneboxSelected)
        searchBar = SearchBar(controller: self, searchHandler: refreshEvents)

        adBar = AdBar(controller: self)

        fetchAddress = FetchAddress(completionHandler: addressFoundHandler)

        view.layoutIfNeeded()
        
        loadViewController()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        adBar?.setupAccessToken()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        titleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventStreamViewController.refreshButtonTapped(_:)))
        titleTapGestureRecognizer?.delegate = self
        navigationTitle.userInteractionEnabled = true
        navigationTitle.addGestureRecognizer(titleTapGestureRecognizer!)
        
        // custom navigation styling
        let customNavBlur = customNavigationView.addDarkBlurOverlay()
        customNavigationView.insertSubview(customNavBlur, atIndex: 0)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setTitle("", "")
        navigationItem.title = ""

        // So we show a white chevron back button when we navigate to other views.
        // Do not attempt to set the window.tintColor globally,
        // as it messes with the tint of the UIActivityViewController and MFMailComposeViewController.
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        searchTextCancelButton.alpha = 0
    }

    func addressFoundHandler(optionalPlacemark: CLPlacemark?) {
        if self.locationSearchField.text != "" {
            CLSNSLogv("%@", getVaList(["Not resetting already-set location field, so ignoring GPS lookup results."]))
            return
        }

        if let placemark = optionalPlacemark {
            CLSNSLogv("%@", getVaList(["EventStreamViewController.addressFoundHandler placemark: \(placemark.description)"]))
            let fields = [placemark.locality, placemark.administrativeArea, placemark.country]
            let setFields = fields.filter({ (elem: String?) -> Bool in
                return elem != nil
            }).map({ (elem: String?) -> String in
                return elem!
            })
            let fullText = setFields.joinWithSeparator(", ")
            self.locationSearchField.text = fullText
            CLSNSLogv("%@", getVaList(["EventStreamViewController.addressFoundHandler locationSearchField: \(self.locationSearchField.text ?? "Unknown")"]))
            CLSNSLogv("%@", getVaList(["EventStreamViewController.addressFoundHandler keywordSearchField: \(self.keywordSearchField.text ?? "Unknown")"]))
            ServerInterface.searchEvents(self.locationSearchField.text!, withKeywords:self.keywordSearchField.text!, completion:self.setupEventsDisplay)
        } else {
            if let location = NSUserDefaults.standardUserDefaults().stringForKey(USER_SEARCH_LOCATION_KEY) {
                CLSNSLogv("%@", getVaList(["addressFoundHandler savedLocation: \(location)"]))
                self.locationSearchField.text = location
                refreshEvents()
            } else {
                CLSNSLogv("%@", getVaList(["addressFoundHandler No Location"]))
                setTitle(NSLocalizedString("RETRY", comment: "Title"), NSLocalizedString("Couldn't detect your location", comment: "GPS Failure"))
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

    func setupEventsDisplay(results: SearchResults?, error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (error != nil) {
                let errorAlert = UIAlertView(title: NSLocalizedString("No Connection", comment: "Error Title"), message: NSLocalizedString("There might have been a network problem. Check your connection", comment: "Error Description"), delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                self.setTitle("ERROR", "Try again")
            } else if results == nil {
                let noEventAlert = UIAlertView(title: NSLocalizedString("Error Finding Events", comment: "Error Title"), message: NSLocalizedString("There was an error getting events. Please try again later...", comment: "Error Description"), delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.setTitle(self.locationSearchField.text!, "No Events")
            } else if results?.events.count == 0 {
                let noEventAlert = UIAlertView(title: NSLocalizedString("No Events", comment: "Error Title"), message: NSLocalizedString("There doesn't seem to be any events in that area right now. Try expanding your search criteria?", comment: "Error Description"), delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.setTitle(self.locationSearchField.text!, "No Events")
            } else {
                self.setTitle(self.locationSearchField.text!, "\(self.keywordSearchField.text!) | \(results!.events.count) Events")
            }
            self.eventDisplay!.setup(results, error: error)
        })
    }

    func refreshEvents(location: String, withKeywords keywords: String) {
        if location == "" && keywords == "" {
            fetchAddress = FetchAddress(completionHandler: addressFoundHandler)
            return
        }

        // If we do a search, store the location, in case we can't access GPS next time, we'll have a good cached value
        NSUserDefaults.standardUserDefaults().setObject(location, forKey: USER_SEARCH_LOCATION_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()

        self.setTitle(location, NSLocalizedString("Loading...", comment: "Progress Title"))
        ServerInterface.searchEvents(location, withKeywords:keywords, completion: setupEventsDisplay)
    }

    func refreshEvents() {
        refreshEvents(locationSearchField.text!, withKeywords: keywordSearchField.text!)
    }
    
    func backToView() {
        // Disabled because we decided to focus on event<->event interstitial ads
        //adBar?.maybeShowInterstitialAd()
    }
}
