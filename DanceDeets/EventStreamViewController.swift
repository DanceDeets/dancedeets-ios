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

class EventStreamViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UISearchResultsUpdating,UISearchControllerDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate, UIGestureRecognizerDelegate {
    
    enum SearchMode{
        case CurrentLocation
        case CustomCity
    }
    
    let COLLECTION_VIEW_TOP_MARGIN:CGFloat = 70.0
    let SEARCH_RESULTS_TABLE_VIEW_TOP_OFFSET:CGFloat = 70.0
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    var events:[Event] = []
    var filteredEvents:[Event] = []
    var geocodeSearchString:String? = String() // the string to search
    var displaySearchString:String? = String() // the display string in the title
    var searchMode:SearchMode = SearchMode.CurrentLocation
    var requiresRefresh = true
    var searchResultsGradient:CAGradientLayer?
    var eventStreamGradient:CAGradientLayer?
    var searchResultsTableView:UITableView?
    var searchController:UISearchController?
    var blurOverlay:UIView?
    var selectedIndexPath:NSIndexPath?
    var searchResultsTableViewBottomConstraint:NSLayoutConstraint?
    var titleTapGestureRecognizer:UITapGestureRecognizer?
    var refreshAnimating:Bool = false
    let locationFailure:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
    
    // MARK: Outlets
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var eventCountLabel: UILabel!
    
    // MARK: Action
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        if(events.count > 0){
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            eventCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
        }
        refreshEvents()
    }
    
    @IBAction func searchBarButtonTapped(sender: AnyObject) {
        blurOverlay?.fadeIn(0.4,nil)
        searchController?.searchBar.hidden = false
        self.searchController?.searchBar.becomeFirstResponder()
    }
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("settingsSegue", sender: sender)
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
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        eventStreamGradient?.position = CGPointMake(0, scrollView.contentOffset.y);
        searchResultsGradient?.position = CGPointMake(0, scrollView.contentOffset.y);
        CATransaction.commit()
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(scrollView == eventCollectionView){
            // updates the highlighted page control
            let flowLayout:UICollectionViewFlowLayout? = eventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
            let itemHeight = Int(flowLayout!.itemSize.height)
            let targetOff = Int(targetContentOffset.memory.y)
        }
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViewController()
        loadSearchController()
        
        locationManager.requestWhenInUseAuthorization()
        
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
        flowLayout?.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height - COLLECTION_VIEW_TOP_MARGIN)
        flowLayout?.minimumInteritemSpacing = 0.0
        
        blurOverlay = view.addDarkBlurOverlay()
        blurOverlay?.alpha = 0
        
        titleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "refreshButtonTapped:")
        titleTapGestureRecognizer?.delegate = self
        navigationTitle.userInteractionEnabled = true
        navigationTitle.addGestureRecognizer(titleTapGestureRecognizer!)
        
        eventCountLabel.textColor = ColorFactory.white50()
        eventCountLabel.font = FontFactory.eventDescriptionFont()
        eventCountLabel.text = ""
        refreshButton.tintColor = ColorFactory.white50()
        refreshButton.hidden = true
        
        // gradient fade out at top
        eventStreamGradient = CAGradientLayer()
        let outerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor
        let innerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(1.0).CGColor
        eventStreamGradient?.colors = [outerColor,innerColor,innerColor]
        eventStreamGradient?.locations = [NSNumber(float: 0.0), NSNumber(float:0.03), NSNumber(float: 1.0)]
        eventStreamGradient?.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-COLLECTION_VIEW_TOP_MARGIN)
        eventStreamGradient?.anchorPoint = CGPoint.zeroPoint
        eventCollectionView!.layer.mask = eventStreamGradient
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        
        
        let locationObject:CLLocation = locations.first as CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if( placemarks != nil && placemarks.count > 0){
                let placemark:CLPlacemark = placemarks.first as CLPlacemark
                self.geocodeSearchString = ""
                if(placemark.locality != nil && placemark.administrativeArea != nil){
                    self.displaySearchString = "\(placemark.locality), \(placemark.administrativeArea)"
                }else{
                    self.displaySearchString = placemark.locality
                }
                Event.loadEventsForLocation(locationObject, completion:self.refreshCityCompletionHandler)
            }else{
                self.navigationTitle.text = "RETRY"
                self.eventCountLabel.text = ""
                self.stopSpin()
                self.locationFailure.show()
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        navigationTitle.text = "RETRY"
        eventCountLabel.text = ""
        stopSpin()
        locationFailure.show()
    }
    
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredEvents.count
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("filteredEventCell", forIndexPath: indexPath) as SearchResultsTableCell
        let event:Event = self.filteredEvents[indexPath.row]
        cell.updateForEvent(event)
        return cell
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
            geocodeSearchString = searchCity
            displaySearchString = searchCity
            navigationTitle.text = displaySearchString?.uppercaseString
            eventCountLabel.text = "Loading..."
            Event.loadEventsForCity(geocodeSearchString!, completion: refreshCityCompletionHandler)
        }else{
            searchMode = SearchMode.CurrentLocation
            geocodeSearchString = ""
            locationManager.startUpdatingLocation()
            navigationTitle.text = "UPDATING LOCATION"
            eventCountLabel.text = ""
        }
    }
    
    func refreshCityCompletionHandler(events:[Event]!, error:NSError!){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.stopSpin()
            // check response
            if(error != nil){
                let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                errorAlert.show()
                self.events = []
                self.eventCollectionView.reloadData()
                self.eventCountLabel.text = "Try again"
            }else if(events.count == 0){
                let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                noEventAlert.show()
                self.events = []
                self.eventCollectionView.reloadData()
                self.eventCountLabel.text = "\(events.count) Events"
            }else{
                self.navigationTitle.text = self.displaySearchString!.uppercaseString
                self.events = events
                self.eventCollectionView.reloadData()
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.eventCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.None, animated: true)
                self.eventCountLabel.text = "\(events.count) Events"
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
    }
    
    func handleKeyboardHidden(notification:NSNotification){
        if searchResultsTableViewBottomConstraint != nil{
            searchResultsTableView?.superview?.removeConstraint(searchResultsTableViewBottomConstraint!)
        }
        
        searchResultsTableViewBottomConstraint = NSLayoutConstraint(item: searchResultsTableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: searchResultsTableView?.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        searchResultsTableView?.superview?.addConstraint(searchResultsTableViewBottomConstraint!)
        searchResultsTableView?.superview?.layoutIfNeeded()
    }
    
    func segueIntoEventDetail(event:Event){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.eventCollectionView.userInteractionEnabled = false
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
