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

class EventStreamViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate/*, UITextFieldDelegate*/ {
    
    enum SearchMode{
        case CurrentLocation
        case CustomCity
    }
    
    // MARK: Constants
    let CUSTOM_NAVIGATION_BAR_HEIGHT:CGFloat = 120.0
    let SEARCH_AUTOSUGGEST_TERMS:[String] = ["All","Bboy","Breaking","Hip-Hop", "House","Popping","Locking","Waacking","Dancehall","Vogue","Krumping","Turfing","Litefeet","Flexing","Bebop","All-Styles"]
    
    // MARK: Variables
    var myLocationManager:CLLocationManager = CLLocationManager()
    var geocoder:CLGeocoder = CLGeocoder()
    var locationFailureAlert:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
    var events:[Event] = []
    var filteredEvents:[Event] = []
    var displaySearchString:String = String()
    var searchMode:SearchMode = .CurrentLocation
    var searchKeyword:String = "All"
    var requiresRefresh = true
    var blurOverlay:UIView!
    var searchResultsTableViewBottomConstraint:NSLayoutConstraint?
    var titleTapGestureRecognizer:UITapGestureRecognizer?
    var eventsBySection:NSMutableDictionary = NSMutableDictionary()
    var sectionNames:NSMutableArray = NSMutableArray()
    var activeYears:[Int] = []
    var locationObject:CLLocation? = nil

    // MARK: Outlets
    @IBOutlet weak var eventListTableView: UITableView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var eventCountLabel: UILabel!
    @IBOutlet weak var customNavigationView: UIView!
    @IBOutlet weak var customNavigationViewHeightConstraint: NSLayoutConstraint!
    /*
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextCancelButton: UIButton!
    @IBOutlet weak var searchTextTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchAutoSuggestTableView: UITableView!
    */
    
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
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        
        eventListTableView.reloadData()

        loadViewController()
        
        myLocationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        /*
        searchTextField.endEditing(true)
        */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(requiresRefresh){
            requiresRefresh = false
            searchKeyword = "All"
            refreshEvents()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkFaceBookToken()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingsSegue"{
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
    
    // MARK: Private
    
    func registerNotifications(){
        // notifications for keyboard
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleKeyboardShown:",
            name: UIKeyboardDidShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleKeyboardHidden:",
            name: UIKeyboardDidHideNotification,
            object: nil)
    }
    
    func loadViewController(){
        
        myLocationManager.delegate = self
        
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
        let placeholder = NSMutableAttributedString(string: "Search")
        placeholder.setColor(ColorFactory.white50())
        placeholder.setFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!)
        /*
        searchTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        searchTextField.attributedPlaceholder = placeholder
        searchTextField.tintColor = ColorFactory.white50()
        searchTextField.textColor = ColorFactory.white50()
        searchTextField.delegate = self
        searchTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        */
        
        let imageView:UIImageView = UIImageView(image: UIImage(named: "searchIconSmall")!)
        imageView.tintColor = ColorFactory.white50()
        imageView.contentMode = UIViewContentMode.Right
        imageView.frame = CGRectMake(0, 0, imageView.image!.size.width + 10, imageView.image!.size.height)
        /*
        searchTextField.leftView = imageView
        searchTextField.leftViewMode = UITextFieldViewMode.UnlessEditing
        searchTextField.textAlignment = .Left
        */
        
        // event list view styling
        eventListTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        eventListTableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12)
        eventListTableView.layoutMargins = UIEdgeInsetsZero
        eventListTableView.delegate = self
        eventListTableView.dataSource = self
        eventListTableView.rowHeight = UITableViewAutomaticDimension
        eventListTableView.estimatedRowHeight = 142
        eventListTableView.backgroundColor = UIColor.clearColor()
        eventListTableView.contentInset = UIEdgeInsetsMake(CUSTOM_NAVIGATION_BAR_HEIGHT, 0, 0, 0)

        /*
        // blur overlay is used for background of auto suggest table
        blurOverlay = view.addDarkBlurOverlay()
        view.insertSubview(blurOverlay!, belowSubview: searchAutoSuggestTableView)
        blurOverlay?.alpha = 0
        */
    }
    
    /*
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // tapped 'search' on the keyboard
        textField.resignFirstResponder()
        searchKeyword = textField.text!
        hideAutoSuggestTable()
        refreshEvents()
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        showAutoSuggestTable()
    }
    */
    
    func completionHandler(placemarks:[CLPlacemark]?, error:NSError?) {
        if( placemarks != nil && placemarks!.count > 0){
            let placemark:CLPlacemark = placemarks!.first!
            self.displaySearchString = "\(placemark.locality!), \(placemark.administrativeArea!)"
            if(self.searchKeyword == "All"){
                Event.loadEventsForLocation(self.locationObject!, keyword:nil, completion:self.refreshCityCompletionHandler)
            }else{
                Event.loadEventsForLocation(self.locationObject!, keyword:self.searchKeyword, completion:self.refreshCityCompletionHandler)
            }
        }else{
            self.showLocationFailure()
        }
    }

    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        myLocationManager.stopUpdatingLocation()
        
        if(locations.count == 0){
            showLocationFailure()
        }else{
            if let locationObject:CLLocation = locations.first! as CLLocation {
                self.locationObject = locationObject
                geocoder.reverseGeocodeLocation(locationObject, completionHandler: completionHandler)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        myLocationManager.stopUpdatingLocation()
        showLocationFailure()
    }
    
    func showLocationFailure(){
        navigationTitle.text = "RETRY"
        eventCountLabel.text = "Couldn't get your location"
        locationFailureAlert.show()
    }
    
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(tableView == eventListTableView){
            return sectionNames.count
        /*
        }else if(tableView == searchAutoSuggestTableView){
            return 1
        */
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == eventListTableView){
            let sectionName = sectionNames[section] as! String
            let events = eventsBySection[sectionName] as! NSArray
            return events.count
        /*
        }else if(tableView == searchAutoSuggestTableView){
            return SEARCH_AUTOSUGGEST_TERMS.count
        */
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(tableView == eventListTableView){
            return 41
        /*
        }else if(tableView == searchAutoSuggestTableView){
            return CGFloat.min
        */
        }else{
            return CGFloat.min
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView == eventListTableView){
            // headers are the mo/yr for a section of events
            let headerView = UIView(frame: CGRectZero)
            headerView.backgroundColor = UIColor.clearColor()
            headerView.addDarkBlurOverlay()
            let headerLabel = UILabel(frame: CGRectZero)
            let sectionName = sectionNames[section] as! String
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(headerLabel)
            headerLabel.constrainLeftToSuperView(13)
            headerLabel.verticallyCenterToSuperView(0)
            headerLabel.font = UIFont(name:"Interstate-BoldCondensed",size:15)!
            headerLabel.textColor = UIColor.whiteColor()
            headerLabel.text = sectionName
            return headerView
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == eventListTableView){
            let sectionName = self.sectionNames[indexPath.section] as! String
            let sectionEvents = self.eventsBySection[sectionName] as! [Event]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("eventListTableViewCell", forIndexPath: indexPath) as! EventListItemTableViewCell
            let event:Event = sectionEvents[indexPath.row]
            cell.updateForEvent(event)
            
            if let imageUrl = event.eventSmallImageUrl {
                let imageRequest:NSURLRequest = NSURLRequest(URL: imageUrl)
                if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                    cell.eventImageView?.image = image
                }else{
                    cell.eventImageView?.image = nil
                    event.downloadSmallImage({ (image:UIImage!, error:NSError!) -> Void in
                        // guard against cell reuse + async download
                        if(event == cell.currentEvent){
                            if(image != nil) {
                                cell.eventImageView?.image = image
                            }
                        }
                    })
                }
            }else{
                cell.eventImageView?.image = nil
            }
            return cell
        /*
        }else if(tableView == searchAutoSuggestTableView){
            let cell = tableView.dequeueReusableCellWithIdentifier("autoSuggestCell", forIndexPath: indexPath) as! SearchAutoSuggestTableCell
            let term = SEARCH_AUTOSUGGEST_TERMS[indexPath.row]
            cell.titleLabel!.text = term
            return cell
        */
        }else{
            // shouldn't happen
            return tableView.dequeueReusableCellWithIdentifier("autoSuggestCell", forIndexPath: indexPath) as! SearchAutoSuggestTableCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView == eventListTableView){
            if let sectionName = self.sectionNames[indexPath.section] as? String{
                if let sectionEvents = self.eventsBySection[sectionName] as? [Event]{
                    if(sectionEvents.count > indexPath.row){
                        let event = sectionEvents[indexPath.row]

                        // the collection cell of the selected event
                        let eventCell =  self.eventListTableView.cellForRowAtIndexPath(indexPath) as! EventListItemTableViewCell
                        
                        let destination = self.storyboard?.instantiateViewControllerWithIdentifier("eventDetailViewController") as! EventDetailViewController
                        destination.initialImage = eventCell.eventImageView.image
                        destination.event = event
                        
                        self.navigationController?.pushViewController(destination, animated: true)
                    }
                }
            }
        /*
        }else if(tableView == searchAutoSuggestTableView){
            let term = SEARCH_AUTOSUGGEST_TERMS[indexPath.row] as String
            searchKeyword = term
            hideAutoSuggestTable()
            
            refreshEvents()
        */
        }
    }
    /*
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
    
    func refreshEvents(){
        let searchCity = UserSettings.getUserCitySearch()
        if(searchCity.characters.count > 0){
            searchMode = SearchMode.CustomCity
            displaySearchString = searchCity
            navigationTitle.text = displaySearchString.uppercaseString
            eventCountLabel.text = "Loading..."
            if(searchKeyword == "All"){
                Event.loadEventsForCity(displaySearchString, keyword:nil, completion: refreshCityCompletionHandler)
            }else{
                Event.loadEventsForCity(displaySearchString, keyword:searchKeyword, completion: refreshCityCompletionHandler)
            }
        }else{
            searchMode = SearchMode.CurrentLocation
            myLocationManager.startUpdatingLocation()
            navigationTitle.text = "UPDATING LOCATION"
            eventCountLabel.text = "Updating Location..."
        }
    }
    
    func refreshCityCompletionHandler(events:[Event]!, error:NSError!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // reset event models
            self.events = []
            self.eventsBySection.removeAllObjects()
            self.activeYears.removeAll(keepCapacity: false)
            self.sectionNames.removeAllObjects()
            
            // check response
            if(error != nil){
                self.navigationTitle.text = "ERROR"
                let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                self.eventListTableView.reloadData()
                self.eventCountLabel.text = "Try again"
            }else if(events.count == 0){
                self.navigationTitle.text = self.displaySearchString.uppercaseString
                let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.eventListTableView.reloadData()
                self.eventCountLabel.text = "No Events"
            }else{
                self.navigationTitle.text = self.displaySearchString.uppercaseString
                self.eventCountLabel.text = "\(self.searchKeyword) | \(events.count) Events"
                
                // data source for collection view
                self.events = events
                
                // data source for list view -> group events into sections by month (or day?)
                for event in events {
                    if event.startTime != nil {
                        // month from event's start time as a string
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "EEE MMM d"
                        let sectionName = dateFormatter.stringFromDate(event.startTime!)
                        // each section has an array of events
                        var eventList:NSMutableArray? = self.eventsBySection[sectionName] as? NSMutableArray
                        if (eventList == nil) {
                            eventList = NSMutableArray()
                            self.eventsBySection[sectionName] = eventList
                        }
                        eventList?.addObject(event)
                        
                        // keep track of active sections for section headers
                        if (!self.sectionNames.containsObject(sectionName)) {
                            self.sectionNames.addObject(sectionName)
                        }
                    }
                }
                self.eventListTableView.reloadData()
                if (self.eventListTableView.numberOfSections > 0 && self.eventListTableView.numberOfRowsInSection(0) > 0){
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.eventListTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
                }
            }
        })
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredEvents = events.filter({( event: Event) -> Bool in
            // simple filter, check is search text is in title or tags
            if (event.title?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil){
                return true;
            }
            for keyword in event.keywords {
                if(keyword.lowercaseString.rangeOfString(searchText.lowercaseString) != nil){
                    return true
                }
            }
            return false;
        })
    }
    
    func checkFaceBookToken(){
        let token = FBSDKAccessToken.currentAccessToken()
        if(token == nil){
            self.navigationController?.performSegueWithIdentifier("presentFacebookLogin", sender: self)
        } else if (!token.hasGranted("user_events")) {
            // This user_events check is because for awhile we allowed iOS access without requesting this permission,
            // and now we wish these users to re-authorize with the additional permissions, even if they have a token.
            let login = FBSDKLoginManager()
            login.logInWithReadPermissions(["user_events"], fromViewController:self, handler: {  (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                ServerInterface.sharedInstance.updateFacebookToken()
            });
        } else {
            AnalyticsUtil.login()
            FBSDKAccessToken.refreshCurrentAccessToken({ (connect:FBSDKGraphRequestConnection!, obj:AnyObject!, error:NSError!) -> Void in
                ServerInterface.sharedInstance.updateFacebookToken()
            })
        }
    }
    
}
