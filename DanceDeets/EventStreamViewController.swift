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

class EventStreamViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    enum SearchMode{
        case CurrentLocation
        case CustomCity
    }
    
    enum ViewMode{
        case CollectionView
        case ListView
    }
    
    // MARK: Constants
    let CUSTOM_NAVIGATION_BAR_HEIGHT:CGFloat = 120.0
    let SEARCH_AUTOSUGGEST_TERMS:[String] = ["All","Bboy","Breaking","Hip-Hop", "House","Popping","Locking","Waacking","Dancehall","Vogue","Krumping","Turfing","Litefeet","Flexing","Bebop","All-Styles"]
    
    // MARK: Variables
    var locationManager:CLLocationManager = CLLocationManager()
    var geocoder:CLGeocoder = CLGeocoder()
    var locationFailureAlert:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
    var events:[Event] = []
    var filteredEvents:[Event] = []
    var displaySearchString:String = String()
    var searchMode:SearchMode = .CurrentLocation
    var searchKeyword:String = "All"
    var viewMode:ViewMode = .CollectionView
    var requiresRefresh = true
    var blurOverlay:UIView!
    var searchResultsTableViewBottomConstraint:NSLayoutConstraint?
    var titleTapGestureRecognizer:UITapGestureRecognizer?
    var refreshAnimating:Bool = false
    var eventsByMonth:NSMutableDictionary = NSMutableDictionary()
    var activeMonths:NSMutableArray = NSMutableArray()
    var activeYears:[Int] = []
    
    // MARK: Outlets
    @IBOutlet weak var eventListTableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var eventCountLabel: UILabel!
    @IBOutlet weak var customNavigationView: UIView!
    @IBOutlet weak var customNavigationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var settingsIcon: UIImageView!
    @IBOutlet weak var collectionModeImageView: UIImageView!
    @IBOutlet weak var listModeImageView: UIImageView!
    @IBOutlet weak var scrollUpButton: UIButton!
    @IBOutlet weak var searchTextCancelButton: UIButton!
    @IBOutlet weak var searchTextTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchAutoSuggestTableView: UITableView!
    
    // MARK: Action
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        refreshEvents()
    }
    
    @IBAction func scrollUpButtonTapped(sender: AnyObject) {
        if(viewMode == .ListView){
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            eventListTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }else if(viewMode == .CollectionView){
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            eventCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
        }
    }
    
    @IBAction func searchTextCancelButtonTapped(sender: AnyObject) {
        hideAutoSuggestTable()
    }
    
    @IBAction func viewModeButtonTapped(sender: AnyObject) {
        if(viewMode == .CollectionView){
            toggleMode(.ListView)
        }else if(viewMode == .ListView){
            toggleMode(.CollectionView)
        }
    }
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("settingsSegue", sender: sender)
    }
    
    func toggleMode(mode:ViewMode){
        if(mode == .CollectionView){
            viewMode = .CollectionView
            collectionModeImageView.hidden = true
            listModeImageView.hidden = false
            eventListTableView.hidden = true
            eventCollectionView.hidden = false
            eventCollectionView.reloadData()
        }else if(mode == .ListView){
            viewMode = .ListView
            collectionModeImageView.hidden = false
            listModeImageView.hidden = true
            eventListTableView.hidden = false
            eventCollectionView.hidden = true
            eventListTableView.reloadData()
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        
        toggleMode(.CollectionView)
        
        loadViewController()
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.endEditing(true)
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
            var destination:SettingsViewController? = segue.destinationViewController as? SettingsViewController
            
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
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let event = events[indexPath.row]
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        eventCollectionView.userInteractionEnabled = false
        event.getMoreDetails({ () -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            dispatch_async(dispatch_get_main_queue(), {
                self.eventCollectionView.userInteractionEnabled = true
                
                // the collection cell of the selected event
                let eventCell = self.eventCollectionView.cellForItemAtIndexPath(indexPath) as! EventCollectionViewCell
                
                // convert event cover image relative to view controller view
                let convertCoverImageRect = self.view.convertRect(eventCell.eventCoverImage.frame, fromView: eventCell.contentView)
                
                // set up destination view controller w/ cover image dimensions
                let destination = self.storyboard?.instantiateViewControllerWithIdentifier("eventDetailViewController") as! EventDetailViewController
                destination.initialImage = eventCell.eventCoverImage.image
                destination.event = event
                destination.COVER_IMAGE_TOP_OFFSET = convertCoverImageRect.origin.y
                destination.COVER_IMAGE_HEIGHT = convertCoverImageRect.size.height
                destination.COVER_IMAGE_LEFT_OFFSET = convertCoverImageRect.origin.x
                destination.COVER_IMAGE_RIGHT_OFFSET = self.view.frame.size.width - convertCoverImageRect.origin.x - convertCoverImageRect.size.width
                
                self.navigationController?.pushViewController(destination, animated: false)
            })
        })
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return events.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell:EventCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as! EventCollectionViewCell
        let event = events[indexPath.row] as Event
        cell.updateForEvent(event)
        
        if let imageUrl = event.eventImageUrl{
            let imageRequest:NSURLRequest = NSURLRequest(URL: imageUrl)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                cell.eventCoverImage?.image = image
            }else{
                cell.eventCoverImage?.image = nil
                event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    // guard against cell reuse + async download
                    if(event == cell.currentEvent){
                        if(image != nil){
                            cell.eventCoverImage?.image = image
                        }
                    }
                })
            }
        }else{
            cell.eventCoverImage?.image = nil
        }
        
        // prefetch next image if possible
        if(indexPath.row < events.count - 1){
            let prefetchEvent:Event = events[indexPath.row + 1]
            if let imageUrl = prefetchEvent.eventImageUrl{
                let imageRequest:NSURLRequest = NSURLRequest(URL: imageUrl)
                if ImageCache.sharedInstance.cachedImageForRequest(imageRequest) ==  nil{
                    prefetchEvent.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    })
                }
            }
        }
        
        return cell
    }
    
    // MARK: Private
    func rotateRefresh(options: UIViewAnimationOptions){
        // animation block, calling itself on completion to give the infinite spin effect
        UIView.animateWithDuration(0.5, delay: 0, options: options, animations: { () -> Void in
            self.refreshButton.transform = CGAffineTransformRotate(self.refreshButton.transform, CGFloat(M_PI_2))
            }) { (bool:Bool) -> Void in
                if bool {
                    if(self.refreshAnimating){
                        self.rotateRefresh(UIViewAnimationOptions.CurveLinear)
                    }else if (options != UIViewAnimationOptions.CurveEaseOut){
                        self.rotateRefresh(UIViewAnimationOptions.CurveEaseOut)
                        self.refreshButton.hidden = true
                    }
                }
                return;
        }
    }
    
    func startSpin(){
        if(!refreshAnimating){
            refreshAnimating = true
            refreshButton.hidden = false
            rotateRefresh(UIViewAnimationOptions.CurveEaseIn)
        }
    }
    
    func stopSpin(){
        refreshAnimating = false
    }
    
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
        
        locationManager.delegate = self
        
        // auto suggest terms when search text field is tapped
        searchAutoSuggestTableView.alpha = 0
        searchAutoSuggestTableView.backgroundColor = UIColor.clearColor()
        searchAutoSuggestTableView.delegate = self
        searchAutoSuggestTableView.dataSource = self
        searchAutoSuggestTableView.registerClass(SearchAutoSuggestTableCell.classForCoder(), forCellReuseIdentifier: "autoSuggestCell")
        searchAutoSuggestTableView.contentInset = UIEdgeInsetsMake(0, 0, 300, 0)
        
        eventCollectionView.delegate = self
        eventCollectionView.dataSource = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationTitle.textColor = UIColor.whiteColor()
        navigationTitle.font = FontFactory.navigationTitleFont()
        navigationTitle.text = ""
        navigationItem.title = ""
        
        let flowLayout:UICollectionViewFlowLayout? = eventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.sectionInset = UIEdgeInsetsZero
        flowLayout?.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height)
        flowLayout?.minimumInteritemSpacing = 0.0
        
        blurOverlay = view.addDarkBlurOverlay()
        view.insertSubview(blurOverlay!, belowSubview: customNavigationView)
        blurOverlay?.alpha = 0
        
        // tapping on the title does a refresh
        titleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "refreshButtonTapped:")
        titleTapGestureRecognizer?.delegate = self
        navigationTitle.userInteractionEnabled = true
        navigationTitle.addGestureRecognizer(titleTapGestureRecognizer!)
        
        // labels / icons
        scrollUpButton.tintColor = UIColor.whiteColor()
        settingsIcon.tintColor = ColorFactory.white50()
        collectionModeImageView.tintColor = ColorFactory.white50()
        listModeImageView.tintColor = ColorFactory.white50()
        eventCountLabel.textColor = ColorFactory.white50()
        eventCountLabel.font = FontFactory.eventDescriptionFont()
        eventCountLabel.text = ""
        refreshButton.tintColor = ColorFactory.white50()
        refreshButton.hidden = true
        searchTextCancelButton.alpha = 0.0
        searchTextCancelButton.tintColor = ColorFactory.white50()
 
        // custom navigation bar
        var customNavBlur = customNavigationView.addDarkBlurOverlay()
        customNavigationView.insertSubview(customNavBlur, atIndex: 0)
       
        // search text field styling
        var placeholder = NSMutableAttributedString(string: "Search")
        placeholder.setColor(ColorFactory.white50())
        placeholder.setFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!)
        searchTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        searchTextField.attributedPlaceholder = placeholder
        searchTextField.tintColor = ColorFactory.white50()
        searchTextField.textColor = ColorFactory.white50()
        searchTextField.delegate = self
        searchTextField.clearButtonMode = UITextFieldViewMode.WhileEditing
        
        let imageView:UIImageView = UIImageView(image: UIImage(named: "searchIconSmall")!)
        imageView.tintColor = ColorFactory.white50()
        imageView.contentMode = UIViewContentMode.Right
        let magGlassXOffset = (searchTextField.frame.size.width / 2 ) - 19.0
        imageView.frame = CGRectMake(0, 0, imageView.image!.size.width + 10, imageView.image!.size.height)
        searchTextField.leftView = imageView
        searchTextField.leftViewMode = UITextFieldViewMode.UnlessEditing
        searchTextField.textAlignment = .Left
        
        // event list view styling
        eventListTableView.separatorColor = ColorFactory.white50()
        eventListTableView.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12)
        eventListTableView.layoutMargins = UIEdgeInsetsZero
        eventListTableView.registerClass(EventListItemTableViewCell.classForCoder(), forCellReuseIdentifier:"eventListTableViewCell")
        eventListTableView.delegate = self
        eventListTableView.dataSource = self
        eventListTableView.rowHeight = UITableViewAutomaticDimension
        eventListTableView.estimatedRowHeight = 142
        eventListTableView.backgroundColor = UIColor.clearColor()
        eventListTableView.contentInset = UIEdgeInsetsMake(CUSTOM_NAVIGATION_BAR_HEIGHT, 0, 0, 0)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // clicked search on the keyboard
        textField.resignFirstResponder()
        searchKeyword = textField.text
        hideAutoSuggestTable()
        refreshEvents()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        showAutoSuggestTable()
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        
        
        let locationObject:CLLocation = locations.first as! CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if( placemarks != nil && placemarks.count > 0){
                let placemark:CLPlacemark = placemarks.first as! CLPlacemark
                if(placemark.locality != nil && placemark.administrativeArea != nil){
                    self.displaySearchString = "\(placemark.locality), \(placemark.administrativeArea)"
                }else{
                    self.displaySearchString = placemark.locality
                }
                if(self.searchKeyword == "All"){
                    Event.loadEventsForLocation(locationObject, keyword:nil, completion:self.refreshCityCompletionHandler)
                }else{
                    Event.loadEventsForLocation(locationObject, keyword:self.searchKeyword, completion:self.refreshCityCompletionHandler)
                }
            }else{
                self.navigationTitle.text = "RETRY"
                self.eventCountLabel.text = "Couldn't get your location"
                self.stopSpin()
                self.locationFailureAlert.show()
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        navigationTitle.text = "RETRY"
        eventCountLabel.text = "Couldn't get your location"
        stopSpin()
        locationFailureAlert.show()
    }
    
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(tableView == eventListTableView){
            return activeMonths.count
        }else if(tableView == searchAutoSuggestTableView){
            return 1
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == eventListTableView){
            let month = activeMonths[section] as! String
            let events = eventsByMonth[month] as! NSArray
            return events.count
        }else if(tableView == searchAutoSuggestTableView){
            return SEARCH_AUTOSUGGEST_TERMS.count
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
        }else{
            return CGFloat.min
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView == eventListTableView){
            // headers are the mo/yr for a section of events
            let headerView = UIView(frame: CGRectZero)
            headerView.backgroundColor = UIColor.clearColor()
            let blur = headerView.addDarkBlurOverlay()
            let headerLabel = UILabel(frame: CGRectZero)
            var monthString = activeMonths[section] as! String
            var monthEvents = eventsByMonth[monthString] as! [Event]
            let year = activeYears[section] as Int
            monthString = "\(monthString.uppercaseString) \(year)"
            headerLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            headerView.addSubview(headerLabel)
            headerLabel.constrainLeftToSuperView(13)
            headerLabel.verticallyCenterToSuperView(0)
            headerLabel.font = UIFont(name:"Interstate-BoldCondensed",size:15)!
            headerLabel.textColor = UIColor.whiteColor()
            headerLabel.text = monthString
            return headerView
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == eventListTableView){
            let month = self.activeMonths[indexPath.section] as! String
            let monthEvents = self.eventsByMonth[month] as! [Event]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("eventListTableViewCell", forIndexPath: indexPath) as! EventListItemTableViewCell
            let event:Event = monthEvents[indexPath.row]
            cell.updateForEvent(event)
            
            if event.eventSmallImageUrl != nil{
                let imageRequest:NSURLRequest = NSURLRequest(URL: event.eventSmallImageUrl!)
                if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                    cell.eventImageView?.image = image
                }else{
                    cell.eventImageView?.image = nil
                    event.downloadSmallImage({ (image:UIImage!, error:NSError!) -> Void in
                        // guard against cell reuse + async download
                        if(event == cell.currentEvent){
                            if(image != nil){
                                cell.eventImageView?.image = image
                            }
                        }
                    })
                }
            }else{
                cell.eventImageView?.image = nil
            }
            return cell
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
        if(tableView == eventListTableView){
            let month = self.activeMonths[indexPath.section] as! String
            let monthEvents = self.eventsByMonth[month] as! [Event]
            let event:Event = monthEvents[indexPath.row]
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            eventListTableView.userInteractionEnabled = false
            event.getMoreDetails({ () -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                dispatch_async(dispatch_get_main_queue(), {
                    self.eventListTableView.userInteractionEnabled = true
                    
                    // the collection cell of the selected event
                    let eventCell =  self.eventListTableView.cellForRowAtIndexPath(indexPath) as! EventListItemTableViewCell
                    
                    // convert event cover image relative to view controller view
                    let convertCoverImageRect = self.view.convertRect(eventCell.eventImageView.frame, fromView: eventCell.eventImageView.superview)
                    
                    let destination = self.storyboard?.instantiateViewControllerWithIdentifier("eventDetailViewController") as! EventDetailViewController
                    destination.initialImage = eventCell.eventImageView.image
                    destination.event = event
                    destination.COVER_IMAGE_TOP_OFFSET = convertCoverImageRect.origin.y
                    destination.COVER_IMAGE_HEIGHT = convertCoverImageRect.size.height
                    destination.COVER_IMAGE_LEFT_OFFSET = convertCoverImageRect.origin.x
                    destination.COVER_IMAGE_RIGHT_OFFSET = self.view.frame.size.width - convertCoverImageRect.origin.x - convertCoverImageRect.size.width
                    
                    self.navigationController?.pushViewController(destination, animated: false)
                })
            })
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
    
    // MARK: Private
    func refreshEvents(){
        startSpin()
        let searchCity = UserSettings.getUserCitySearch()
        if(count(searchCity) > 0){
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
            locationManager.startUpdatingLocation()
            navigationTitle.text = "UPDATING LOCATION"
            eventCountLabel.text = "Updating Location..."
        }
    }
    
    func refreshCityCompletionHandler(events:[Event]!, error:NSError!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.stopSpin()
            
            // reset event models
            self.events = []
            self.eventsByMonth.removeAllObjects()
            self.activeYears.removeAll(keepCapacity: false)
            self.activeMonths.removeAllObjects()
            
            // check response
            if(error != nil){
                self.navigationTitle.text = "ERROR"
                let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                self.eventCollectionView.reloadData()
                self.eventCountLabel.text = "Try again"
            }else if(events.count == 0){
                self.navigationTitle.text = self.displaySearchString.uppercaseString
                let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.eventCollectionView.reloadData()
                self.eventCountLabel.text = "No Events"
            }else{
                self.navigationTitle.text = self.displaySearchString.uppercaseString
              //  if let keyword = self.searchKeyword{
                    self.eventCountLabel.text = "\(events.count) Events | \(self.searchKeyword)"
              //  }else{
               //     self.eventCountLabel.text = "\(events.count) Events | All"
               // }
                
                // for collection view
                self.events = events
                self.eventCollectionView.reloadData()
                
                // for the list view -> group events by months for sections
                for event in events {
                    if let time = event.startTime {
                        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay, fromDate: event.startTime!)
                        // month as string
                        let monthString = NSDateFormatter().monthSymbols[components.month-1] as! String
                        
                        // group events into months
                        var eventList:NSMutableArray? = self.eventsByMonth[monthString] as? NSMutableArray
                        if(eventList == nil){
                            eventList = NSMutableArray()
                            self.eventsByMonth[monthString] = eventList
                        }
                        eventList?.addObject(event)
                        
                        // keep track of active month for section headers
                        if(!self.activeMonths.containsObject(monthString)){
                            self.activeMonths.addObject(monthString)
                            self.activeYears.append(components.year)
                        }
                        
                      
                    }
                }
                self.eventListTableView.reloadData()
                self.scrollUpButtonTapped(self)
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
        if(FBSession.activeSession() == nil){
            navigationController?.performSegueWithIdentifier("presentFacebookLogin", sender: self)
        }else{
            let currentState:FBSessionState = FBSession.activeSession().state
            
            if( currentState == FBSessionState.Open ||
                currentState == FBSessionState.OpenTokenExtended){
                    // don't need to do anything if session already open
                    return;
            }else if( currentState == FBSessionState.CreatedTokenLoaded){
                // open up the session
                FBSession.openActiveSessionWithReadPermissions(FaceBookLoginViewController.getDefaultFacebookPermissions, allowLoginUI: false, completionHandler: { (session:FBSession!, state:FBSessionState, error:NSError!) -> Void in
                    
                    // update user location + post token
                    ServerInterface.sharedInstance.updateFacebookToken()
                    
                    // get graph object id
                    FBRequestConnection.startForMeWithCompletionHandler({ (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                        if (error == nil){
                            if let resultDictionary:NSDictionary? = result as? NSDictionary{
                                AppDelegate.sharedInstance().fbGraphUserObjectId = resultDictionary!["id"] as? String
                            }
                        }
                    })
                })
                
            }else{
                navigationController?.performSegueWithIdentifier("presentFacebookLogin", sender: self)
            }
        }
    }
    
}
