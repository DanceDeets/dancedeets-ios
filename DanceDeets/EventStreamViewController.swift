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

class EventStreamViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UISearchResultsUpdating,UISearchControllerDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate {
    
    enum SearchMode{
        case CurrentLocation
        case CustomCity
    }
    
    let COLLECTION_VIEW_TOP_MARGIN:CGFloat = 70.0
    let SEARCH_RESULTS_TABLE_VIEW_TOP_OFFSET:CGFloat = 70.0
    var events:[Event] = []
    var filteredEvents:[Event] = []
    var currentCity:String? = String()
    var searchMode:SearchMode = SearchMode.CurrentLocation
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    var requiresRefresh = true
    var gradientLayer:CAGradientLayer?
    var searchResultsTableView:UITableView?
    var searchController:UISearchController?
    var blurOverlay:UIView?
    
    // MARK: Outlets
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    // MARK: Action
    @IBAction func searchBarButtonTapped(sender: AnyObject) {
        blurOverlay?.fadeIn(0.4)
        searchController?.searchBar.hidden = false
        self.searchController?.searchBar.becomeFirstResponder()
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController){
        filterContentForSearchText(searchController.searchBar.text)
        searchResultsTableView?.reloadData()
    }
    
    // MARK: UISearchControllerDelegate
    func willDismissSearchController(searchController: UISearchController) {
        blurOverlay?.fadeOut(0.4)
        searchController.searchBar.hidden = true
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView == searchResultsTableView){
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradientLayer?.position = CGPointMake(0, scrollView.contentOffset.y);
            CATransaction.commit()
        }
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadViewController()
        self.loadSearchController()
        
        // notification registration
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleKeyboardShown:",
            name: UIKeyboardDidShowNotification,
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        println("EventStreamViewController -> viewWillAppear")
        super.viewWillAppear(animated)
        
        if(requiresRefresh){
            requiresRefresh = false
            refreshEvents()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventDetailSegue"{
            var destination:EventDetailViewController? = segue.destinationViewController as? EventDetailViewController
            let event = sender as? Event
            destination?.event = sender as? Event
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
        var selectedEvent:Event = events[indexPath.row]
        segueIntoEventDetail(selectedEvent)
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return events.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell:EventCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as? EventCollectionViewCell
        let event = events[indexPath.row] as Event
        cell?.updateForEvent(event)
        cell?.eventCoverImage?.image = nil
        
        if event.identifier != nil && event.eventImageUrl != nil{
            let imageRequest:NSURLRequest = NSURLRequest(URL: event.eventImageUrl!)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                cell?.eventCoverImage?.image = image
            }else{
                event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if(image != nil && error == nil){
                        cell?.eventCoverImage?.image = image
                    }
                })
            }
        }
        return cell!
    }
    
    // MARK: Private
    func loadViewController(){
        eventCollectionView.delegate = self
        eventCollectionView.dataSource = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        navigationTitle.textColor = UIColor.whiteColor()
        navigationTitle.font = FontFactory.navigationTitleFont()
        
        eventCollectionView.layoutIfNeeded()
        let flowLayout:UICollectionViewFlowLayout? = eventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.sectionInset = UIEdgeInsetsZero
        flowLayout?.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height - COLLECTION_VIEW_TOP_MARGIN)
        flowLayout?.minimumInteritemSpacing = 0.0
        
        blurOverlay = UIView(frame: CGRectZero)
        self.view.addSubview(blurOverlay!)
        blurOverlay?.constrainToSuperViewEdges()
        
        let overlayView = UIVisualEffectView(effect: UIBlurEffect(style:UIBlurEffectStyle.Dark)) as UIVisualEffectView
        blurOverlay?.addSubview(overlayView)
        overlayView.constrainToSuperViewEdges()
        blurOverlay?.alpha = 0
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        self.title = ""
        
        let locationObject:CLLocation = locations.first as CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if( placemarks != nil && placemarks.count > 0){
                let placemark:CLPlacemark = placemarks.first as CLPlacemark
                self.currentCity = placemark.locality
                self.refreshEventsForCurrentCity()
            }else{
                let locationFailure:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
                locationFailure.show()
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        
        let locationFailure:UIAlertView = UIAlertView(title: "Having some trouble getting your location", message: "", delegate: nil, cancelButtonTitle: "OK")
        locationFailure.show()
    }
    
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("filteredEventCell", forIndexPath: indexPath) as SearchResultsTableCell
        let event:Event = self.filteredEvents[indexPath.row]
        cell.updateForEvent(event)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let event:Event = filteredEvents[indexPath.row]
        self.searchController?.active = false
        segueIntoEventDetail(event)
   
    }
    
    // MARK: Private
    func refreshEvents(){
        // if customCity is set in user defaults, user set a default city to search for events
        // TODO
        //let search:String? = NSUserDefaults.standardUserDefaults().stringForKey("customCity")
        let search:String? = "NEW YORK"
        if(search != nil && countElements(search!) > 0){
            println("Custom search city is set as: " + search!)
            searchMode = SearchMode.CustomCity
            currentCity = search
            refreshEventsForCurrentCity()
        }else{
            println("Custom search city not set, using location manager")
            searchMode = SearchMode.CurrentLocation
            currentCity = ""
            self.title = "Updating Location..."
            locationManager.startUpdatingLocation()
        }
    }
    
    func refreshEventsForCurrentCity(){
        println("Refreshing events for: " + currentCity!)
        self.navigationTitle.text = "LOADING EVENTS..."
        Event.loadEventsForCity(currentCity!, completion: {(events:[Event]!, error:NSError!) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationTitle.text = self.currentCity
                // check response
                if(error != nil){
                    let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                    errorAlert.show()
                }else if(events.count == 0){
                    let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                    noEventAlert.show()
                }else{
                    self.events = events
                    self.eventCollectionView.reloadData()
                }
            })
        })
    }
    
    func loadSearchController()
    {
        // setting up the view controller handling results from the search bar
        var searchVC:UIViewController = UIViewController()
        searchVC.automaticallyAdjustsScrollViewInsets = false
        
        // table view controller listing filtered events
        var tbvc:UITableViewController = UITableViewController(style: UITableViewStyle.Plain)
        tbvc.tableView.delegate = self
        tbvc.tableView.dataSource = self
        tbvc.tableView.backgroundColor = UIColor.clearColor()
        tbvc.tableView.rowHeight = UITableViewAutomaticDimension
        tbvc.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tbvc.tableView.separatorColor = UIColor.whiteColor()
        tbvc.tableView.registerClass(SearchResultsTableCell.classForCoder(), forCellReuseIdentifier: "filteredEventCell")
        
        searchVC.view.addSubview(tbvc.tableView)
        tbvc.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: SEARCH_RESULTS_TABLE_VIEW_TOP_OFFSET))
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
        
        searchResultsTableView = tbvc.tableView
        
        // search controller set upt
        self.searchController = UISearchController(searchResultsController: searchVC)
        self.searchController?.delegate = self
        self.searchController?.searchResultsUpdater = self
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.barStyle = UIBarStyle.Black
        self.searchController?.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.searchController?.searchBar.tintColor = UIColor.whiteColor()
        self.searchController?.searchBar.placeholder = "Filter Dance Events"
        // sets at the top of the main feed
        self.searchController?.searchBar.frame = CGRect(origin: CGPoint(x: 0, y: 10), size: CGSize(width: self.searchController!.searchBar.frame.size.width, height: 44))
        self.searchController?.dimsBackgroundDuringPresentation = true
        self.view.addSubview(self.searchController!.searchBar)
        
        // gradient fade out at top
        gradientLayer = CAGradientLayer()
        let outerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor
        let innerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(1.0).CGColor
        gradientLayer?.colors = [outerColor,innerColor,innerColor]
        gradientLayer?.locations = [NSNumber(float: 0.0), NSNumber(float:0.03), NSNumber(float: 1.0)]
        gradientLayer?.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-SEARCH_RESULTS_TABLE_VIEW_TOP_OFFSET)
        gradientLayer?.anchorPoint = CGPoint.zeroPoint
        searchResultsTableView!.layer.mask = gradientLayer
    }
    
    
    func handleKeyboardShown(notification:NSNotification){
        // when keyboard pops up we want to layout the search results table view to end right at the top of the keyboard
        if let info = notification.userInfo as? Dictionary<String,NSValue> {
            if let keyboardFrame:NSValue = info[UIKeyboardFrameEndUserInfoKey]{
                let frame:CGRect = keyboardFrame.CGRectValue()
                let keyboardHeight = frame.height
                let searchResultsController = self.searchController?.searchResultsController
                searchResultsTableView?.superview?.addConstraint(NSLayoutConstraint(item: searchResultsTableView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: searchResultsTableView?.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -keyboardHeight))
                searchResultsTableView?.superview?.layoutIfNeeded()
            }
        }
    }
    
    func segueIntoEventDetail(event:Event){
        if event.detailsLoaded{
            performSegueWithIdentifier("eventDetailSegue", sender: event)
        }else{
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.eventCollectionView.userInteractionEnabled = false
            event.getMoreDetails({ (error:NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                dispatch_async(dispatch_get_main_queue(), {
                    self.eventCollectionView.userInteractionEnabled = true
                    if(error == nil){
                        self.performSegueWithIdentifier("eventDetailSegue", sender: event)
                    }else{
                        let alert:UIAlertView = UIAlertView(title: "Sorry", message: "Couldn't get the deets to that event right now", delegate: nil, cancelButtonTitle: "OK")
                        alert.show()
                    }
                })
            })
        }
    }

    func filterContentForSearchText(searchText: String) {
        self.filteredEvents = self.events.filter({( event: Event) -> Bool in
            // simple filter, check is search text is in description, title, or tags
            if (event.title?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil){
                return true;
            }
            if(event.tagString?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil){
                return true;
            }
            return false;
        })
    }
    
}