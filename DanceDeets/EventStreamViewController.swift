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
    let CUSTOM_NAVIGATION_BAR_HEIGHT:CGFloat = 90.0
    let SEARCH_AUTOSUGGEST_TERMS:[String] = ["All","Bboy","Breaking","Hip-Hop", "House","Popping","Locking","Waacking","Dancehall","Vogue","Krumping","Turfing","Litefeet","Flexing","Bebop","All-Styles"]
    
    // MARK: Variables
    var locationFailureAlert:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
    var displaySearchString:String = String()
    var searchKeyword:String = ""
    var requiresRefresh = true
    var blurOverlay:UIView!
    var searchResultsTableViewBottomConstraint:NSLayoutConstraint?
    var titleTapGestureRecognizer:UITapGestureRecognizer?
    var currentGeooder:CurrentGeocode?

    var eventDisplay:EventDisplay?

    // MARK: Outlets
    @IBOutlet weak var eventListTableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var eventCountLabel: UILabel!
    @IBOutlet weak var customNavigationView: UIView!
    @IBOutlet weak var customNavigationViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var locationSearchField: UITextField!
    @IBOutlet weak var keywordSearchField: UITextField!
    
    // MARK: Action functions
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        refreshEvents()
    }
    
    /*
    @IBAction func searchTextCancelButtonTapped(sender: AnyObject) {
        hideAutoSuggestTable()
    }
    */
    
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

        view.layoutIfNeeded()
        
        loadViewController()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        /*
        searchTextField.endEditing(true)
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (requiresRefresh) {
            requiresRefresh = false
            currentGeooder = CurrentGeocode(completionHandler: completionHandler)
            searchKeyword = ""
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

    func configureField(field: UITextField, defaultText: String, iconName: String) {
        let placeholder = NSMutableAttributedString(string: defaultText)
        placeholder.setColor(ColorFactory.white50())
        placeholder.setFont(UIFont(name: "Interstate-Light", size: 12.0)!)
        field.attributedPlaceholder = placeholder
        
        let imageView:UIImageView = UIImageView(image: UIImage(named: iconName)!)
        imageView.tintColor = ColorFactory.white50()
        imageView.contentMode = UIViewContentMode.Right
        imageView.frame = CGRectMake(0, 0, imageView.image!.size.width + 10, imageView.image!.size.height)
        field.delegate = self
        field.clearButtonMode = UITextFieldViewMode.WhileEditing
        field.leftView = imageView
        field.leftViewMode = UITextFieldViewMode.Always
        field.textAlignment = .Left
    }

    func loadViewController() {
        // auto suggest terms when search text field is tapped
        /*
        searchAutoSuggestTableView.alpha = 0
        searchAutoSuggestTableView.backgroundColor = UIColor.clearColor()
        searchAutoSuggestTableView.delegate = self
        searchAutoSuggestTableView.dataSource = self
        searchAutoSuggestTableView.registerClass(SearchAutoSuggestTableCell.classForCoder(), forCellReuseIdentifier: "autoSuggestCell")
        searchAutoSuggestTableView.contentInset = UIEdgeInsetsMake(CUSTOM_NAVIGATION_BAR_HEIGHT, 0, 300, 0)
        */
        
        // tapping on the title does a refresh
        titleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "refreshButtonTapped:")
        titleTapGestureRecognizer?.delegate = self
        navigationTitle.userInteractionEnabled = true
        navigationTitle.addGestureRecognizer(titleTapGestureRecognizer!)
        
        // labels / icons
        eventCountLabel.textColor = ColorFactory.white50()
        eventCountLabel.font = FontFactory.eventDescriptionFont()
        eventCountLabel.text = ""
        /*
        searchTextCancelButton.alpha = 0.0
        searchTextCancelButton.tintColor = ColorFactory.white50()
        */
 
        // custom navigation styling
        let customNavBlur = customNavigationView.addDarkBlurOverlay()
        customNavigationView.insertSubview(customNavBlur, atIndex: 0)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationTitle.textColor = UIColor.whiteColor()
        navigationTitle.font = FontFactory.navigationTitleFont()
        navigationTitle.text = ""
        navigationItem.title = ""
       
        // search text field styling
        configureField(locationSearchField, defaultText: "Location", iconName: "pinIcon")
        configureField(keywordSearchField, defaultText: "Keywords", iconName: "searchIconSmall")
        
        // blur overlay is used for background of auto suggest table
        blurOverlay = view.addDarkBlurOverlay()
        view.insertSubview(blurOverlay!, belowSubview: customNavigationView)
        blurOverlay?.alpha = 0
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchKeyword = keywordSearchField.text!
        blurOverlay?.fadeOut(0.5, completion: nil)
        refreshEvents()
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        blurOverlay?.fadeIn(0.5, completion: nil)
    }
    
    func completionHandler(optionalPlacemark: CLPlacemark?) {
        if let placemark = optionalPlacemark {
            self.displaySearchString = "\(placemark.locality!), \(placemark.administrativeArea!)"
            let fullText = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
            self.locationSearchField.text = fullText
            Event.loadEventsForCity(fullText, keyword:self.searchKeyword, completion:self.setupEventsDisplay)
        } else {
            navigationTitle.text = "RETRY"
            eventCountLabel.text = "Couldn't get your location"
            locationFailureAlert.show()
        }
    }

    /*
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        }else if(tableView == searchAutoSuggestTableView){
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        }else if(tableView == searchAutoSuggestTableView){
            return SEARCH_AUTOSUGGEST_TERMS.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        }else if(tableView == searchAutoSuggestTableView){
            let cell = tableView.dequeueReusableCellWithIdentifier("autoSuggestCell", forIndexPath: indexPath) as! SearchAutoSuggestTableCell
            let term = SEARCH_AUTOSUGGEST_TERMS[indexPath.row]
            cell.titleLabel!.text = term
            return cell
        }else{
            // shouldn't happen
            return tableView.dequeueReusableCellWithIdentifier("autoSuggestCell", forIndexPath: indexPath) as! SearchAutoSuggestTableCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        }else if(tableView == searchAutoSuggestTableView){
            let term = SEARCH_AUTOSUGGEST_TERMS[indexPath.row] as String
            searchKeyword = term
            hideAutoSuggestTable()
            
            refreshEvents()
        }
    }

    func showAutoSuggestTable(){
        blurOverlay?.fadeIn(0.5, completion: nil)
        
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextTrailingConstraint.constant = 80
            self.view.layoutIfNeeded()
            }) { (bool:Bool) -> Void in
                return
        }
        UIView.animateWithDuration(0.25, delay: 0.25, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextCancelButton.alpha = 1.0
            self.searchAutoSuggestTableView.alpha = 1.0
            }) { (bool:Bool) -> Void in
                return
        }
       
        searchTextField.text = ""
        searchTextField.becomeFirstResponder()
    }
    
    func hideAutoSuggestTable(){
        blurOverlay?.fadeOut(0.5, completion: nil)
        
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.25, delay: 0.25, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextTrailingConstraint.constant = 12
            self.view.layoutIfNeeded()
            }) { (bool:Bool) -> Void in
                return
        }
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.searchTextCancelButton.alpha = 0
            self.searchAutoSuggestTableView.alpha = 0
            }) { (bool:Bool) -> Void in
                return
        }
        view.endEditing(true)
    }
    */
    
    func setupEventsDisplay(events: [Event]!, error: NSError!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (error != nil) {
                self.navigationTitle.text = "ERROR"
                let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                self.eventCountLabel.text = "Try again"
            } else if(events.count == 0) {
                self.navigationTitle.text = self.displaySearchString.uppercaseString
                let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.eventCountLabel.text = "No Events"
            } else {
                self.navigationTitle.text = self.displaySearchString.uppercaseString
                self.eventCountLabel.text = "\(self.searchKeyword) | \(events.count) Events"
            }
            self.eventDisplay!.setup(events, error: error)
        })
    }

    func refreshEvents() {
        displaySearchString = locationSearchField.text!
        navigationTitle.text = displaySearchString.uppercaseString
        eventCountLabel.text = "Loading..."
        Event.loadEventsForCity(displaySearchString, keyword:searchKeyword, completion: setupEventsDisplay)
    }
    
    func checkFaceBookToken(){
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
