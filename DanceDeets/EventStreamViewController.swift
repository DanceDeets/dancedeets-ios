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

class EventStreamViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UISearchResultsUpdating,UISearchControllerDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    enum SearchMode{
        case CurrentLocation
        case CustomCity
    }
    
    enum ViewMode{
        case CollectionView
        case ListView
    }
    
    // MARK: Constants
    let SEARCH_RESULTS_TABLE_VIEW_TOP_OFFSET:CGFloat = 70.0
    let CUSTOM_NAVIGATION_BAR_HEIGHT:CGFloat = 120.0
    
    // MARK: Variables
    var locationManager:CLLocationManager = CLLocationManager()
    var geocoder:CLGeocoder = CLGeocoder()
    var locationFailureAlert:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
    var events:[Event] = []
    var filteredEvents:[Event] = []
    var displaySearchString:String? = String() // the display string in the title
    var searchMode:SearchMode = .CurrentLocation
    var viewMode:ViewMode = .CollectionView
    var requiresRefresh = true
    var searchResultsGradient:CAGradientLayer?
    var searchResultsTableView:UITableView?
    var searchController:UISearchController?
    var blurOverlay:UIView?
    var selectedIndexPath:NSIndexPath?
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
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController){
        filterContentForSearchText(searchController.searchBar.text)
        searchResultsTableView?.reloadData()
    }
    
    // MARK: UISearchControllerDelegate
    func willDismissSearchController(searchController: UISearchController) {
        blurOverlay?.fadeOut(0.4,nil)
        searchController.searchBar.hidden = true
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
        registerNotifications()
        
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
            let snapShot:UIView = self.view.snapshotViewAfterScreenUpdates(false)
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
        selectedIndexPath = indexPath
        segueIntoEventDetail(events[indexPath.row])
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return events.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell:EventCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as? EventCollectionViewCell
        let event = events[indexPath.row] as Event
        let currentEvent = event
        cell?.updateForEvent(event)
        
        if event.eventImageUrl != nil{
            let imageRequest:NSURLRequest = NSURLRequest(URL: event.eventImageUrl!)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                cell?.eventCoverImage?.image = image
            }else{
                cell?.eventCoverImage?.image = nil
                event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    // guard against cell reuse + async download
                    if(currentEvent == cell?.currentEvent){
                        if(image != nil){
                            cell?.eventCoverImage?.image = image
                        }
                    }
                })
            }
        }else{
            cell?.eventCoverImage?.image = nil
        }
        
        // prefetch next image if possible
        if(indexPath.row < events.count - 1){
            let prefetchEvent:Event = events[indexPath.row + 1]
            if prefetchEvent.eventImageUrl != nil{
                let imageRequest:NSURLRequest = NSURLRequest(URL: prefetchEvent.eventImageUrl!)
                if ImageCache.sharedInstance.cachedImageForRequest(imageRequest) ==  nil{
                    prefetchEvent.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    })
                }
            }
            
        }
        
        return cell!
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
 
        // custom navigation bar
        var viewNav = customNavigationView.addDarkBlurOverlay()
       
        // search text field styling
        var placeholder = NSMutableAttributedString(string: "Search")
        placeholder.setColor(UIColor.whiteColor())
        placeholder.setFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0)!)
        searchTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        searchTextField.attributedPlaceholder = placeholder
        searchTextField.tintColor = UIColor.whiteColor()
        searchTextField.textColor = UIColor.whiteColor()
        searchTextField.delegate = self
        
        let imageView:UIImageView = UIImageView(image: UIImage(named: "searchIconSmall")!)
        imageView.contentMode = UIViewContentMode.Right
        let magGlassXOffset = (searchTextField.frame.size.width / 2 ) - 19.0
        imageView.frame = CGRectMake(0, 0, magGlassXOffset, imageView.image!.size.height)
        imageView.tintColor = UIColor.whiteColor()
        searchTextField.leftView = imageView
        searchTextField.leftViewMode = UITextFieldViewMode.UnlessEditing
        
        
        // event list view 
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
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        
        
        let locationObject:CLLocation = locations.first as CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if( placemarks != nil && placemarks.count > 0){
                let placemark:CLPlacemark = placemarks.first as CLPlacemark
                if(placemark.locality != nil && placemark.administrativeArea != nil){
                    self.displaySearchString = "\(placemark.locality), \(placemark.administrativeArea)"
                }else{
                    self.displaySearchString = placemark.locality
                }
                Event.loadEventsForLocation(locationObject, completion:self.refreshCityCompletionHandler)
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
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == eventListTableView){
            let month = activeMonths[section] as String
            let events = eventsByMonth[month] as NSArray
            return events.count
        }else{
            return self.filteredEvents.count
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
        let headerView = UIView(frame: CGRectZero)
        headerView.backgroundColor = UIColor.clearColor()
        let blur = headerView.addDarkBlurOverlay()
        let headerLabel = UILabel(frame: CGRectZero)
        var monthString = activeMonths[section] as String
        var monthEvents = eventsByMonth[monthString] as [Event]
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
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == eventListTableView){
            let month = self.activeMonths[indexPath.section] as String
            let monthEvents = self.eventsByMonth[month] as [Event]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("eventListTableViewCell", forIndexPath: indexPath) as EventListItemTableViewCell
            let event:Event = monthEvents[indexPath.row]
            //let currentEvent = event
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
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier("filteredEventCell", forIndexPath: indexPath) as SearchResultsTableCell
            let event:Event = self.filteredEvents[indexPath.row]
            cell.updateForEvent(event)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event:Event = filteredEvents[indexPath.row]
        
        // locate the filtered event's position in the main event array
        if let indexPath = find(events,event){
            selectedIndexPath = NSIndexPath(forItem: indexPath, inSection: 0)
            eventCollectionView.scrollToItemAtIndexPath(selectedIndexPath!, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        }
        
        self.searchController?.active = false
        segueIntoEventDetail(event)
    }
    
    // MARK: Private
    func refreshEvents(){
        startSpin()
        let searchCity = UserSettings.getUserCitySearch()
        if(countElements(searchCity) > 0){
            searchMode = SearchMode.CustomCity
            displaySearchString = searchCity
            navigationTitle.text = displaySearchString?.uppercaseString
            eventCountLabel.text = "Loading..."
            Event.loadEventsForCity(displaySearchString!, completion: refreshCityCompletionHandler)
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
                self.navigationTitle.text = self.displaySearchString!.uppercaseString
                let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.eventCollectionView.reloadData()
                self.eventCountLabel.text = "No Events"
            }else{
                self.navigationTitle.text = self.displaySearchString!.uppercaseString
                self.eventCountLabel.text = "\(events.count) Events"
                
                // for collection view
                self.events = events
                self.eventCollectionView.reloadData()
                
                // for the list view -> group events by months for sections
                for event in events {
                    if let time = event.startTime {
                        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: event.startTime!)
                        // month as string
                        let monthString = NSDateFormatter().monthSymbols[components.month-1] as String
                        
                        // group events into its month
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
    
    func loadSearchController()
    {
        // setting up the view controller handling results from the search bar
        var searchVC:UIViewController = UIViewController()
        searchVC.automaticallyAdjustsScrollViewInsets = false
        
        // table view controller whichs lists filtered events
        var tbvc:UITableViewController = UITableViewController(style: UITableViewStyle.Plain)
        tbvc.tableView.delegate = self
        tbvc.tableView.dataSource = self
        tbvc.tableView.backgroundColor = UIColor.clearColor()
        tbvc.tableView.rowHeight = UITableViewAutomaticDimension
        tbvc.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tbvc.tableView.separatorColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        tbvc.tableView.registerClass(SearchResultsTableCell.classForCoder(), forCellReuseIdentifier: "filteredEventCell")
        
        // manually constraint the table view, the bottom constraint is dynamic w/ the keyboard
        searchVC.view.addSubview(tbvc.tableView)
        tbvc.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: SEARCH_RESULTS_TABLE_VIEW_TOP_OFFSET))
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
        
        searchResultsTableView = tbvc.tableView
        
        // search controller set up
        searchController = UISearchController(searchResultsController: searchVC)
        searchController?.delegate = self
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.delegate = self
        searchController?.searchBar.barStyle = UIBarStyle.Black
        searchController?.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController?.searchBar.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        searchController?.searchBar.placeholder = "Filter Dance Events"
        // sets at the top of the main feed
        searchController?.searchBar.frame = CGRect(origin: CGPoint(x: 0, y: 10), size: CGSize(width: self.searchController!.searchBar.frame.size.width, height: 44))
        searchController?.dimsBackgroundDuringPresentation = true
        view.addSubview(searchController!.searchBar)
        
        // gradient fade out at top
        searchResultsGradient = CAGradientLayer()
        let outerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor
        let innerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(1.0).CGColor
        searchResultsGradient?.colors = [outerColor,innerColor,innerColor]
        searchResultsGradient?.locations = [NSNumber(float: 0.0), NSNumber(float:0.03), NSNumber(float: 1.0)]
        searchResultsGradient?.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-SEARCH_RESULTS_TABLE_VIEW_TOP_OFFSET)
        searchResultsGradient?.anchorPoint = CGPoint.zeroPoint
        searchResultsTableView!.layer.mask = searchResultsGradient
    }
    
    func handleKeyboardShown(notification:NSNotification){
        
        /*
        // when keyboard pops up we want to layout the search results table view to end right at the top of the keyboard
        if let info = notification.userInfo as? Dictionary<String,NSValue> {
            if let keyboardFrame:NSValue = info[UIKeyboardFrameEndUserInfoKey]{
                let frame:CGRect = keyboardFrame.CGRectValue()
                let keyboardHeight = frame.height
                let searchResultsController = self.searchController?.searchResultsController
                if searchResultsTableViewBottomConstraint != nil{
                    searchResultsTableView?.superview?.removeConstraint(searchResultsTableViewBottomConstraint!)
                }
                
                searchResultsTableViewBottomConstraint = NSLayoutConstraint(item: searchResultsTableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: searchResultsTableView?.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -keyboardHeight)
                searchResultsTableView?.superview?.addConstraint(searchResultsTableViewBottomConstraint!)
                
                searchResultsTableView?.superview?.layoutIfNeeded()
            }
        }
*/
    }
    
    func handleKeyboardHidden(notification:NSNotification){
        /*
        if searchResultsTableViewBottomConstraint != nil{
            searchResultsTableView?.superview?.removeConstraint(searchResultsTableViewBottomConstraint!)
        }
        
        searchResultsTableViewBottomConstraint = NSLayoutConstraint(item: searchResultsTableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: searchResultsTableView?.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        searchResultsTableView?.superview?.addConstraint(searchResultsTableViewBottomConstraint!)
        searchResultsTableView?.superview?.layoutIfNeeded()
*/
    }
    
    func segueIntoEventDetail(event:Event){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        eventCollectionView.userInteractionEnabled = false
        event.getMoreDetails({ () -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            dispatch_async(dispatch_get_main_queue(), {
                self.eventCollectionView.userInteractionEnabled = true
                
                // the collection cell of the selected event
                let eventCell = self.eventCollectionView.cellForItemAtIndexPath(self.selectedIndexPath!) as EventCollectionViewCell
                
                // convert event cover image relative to view controller view
                let convertCoverImageRect = self.view.convertRect(eventCell.eventCoverImage.frame, fromView: eventCell.contentView)
                
                // set up destination view controller w/ cover image dimensions
                let destination = self.storyboard?.instantiateViewControllerWithIdentifier("eventDetailViewController") as? EventDetailViewController
                destination?.event = event
                destination?.COVER_IMAGE_TOP_OFFSET = convertCoverImageRect.origin.y
                destination?.COVER_IMAGE_HEIGHT = convertCoverImageRect.size.height
                
                self.navigationController?.pushViewController(destination!, animated: false)
            })
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
