//
//  MainFeedViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/22/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import CoreLocation
import MessageUI

enum MainFeedSearchMode{
    case CurrentLocation
    case CustomCity
}

class MainFeedViewController:UIViewController,CLLocationManagerDelegate,UISearchResultsUpdating, UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate{

    var events:[Event] = []
    var filteredEvents:[Event] = []
    var currentCity:String? = String()
    let estimatedEventRowHeight:CGFloat = 600
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    var searchMode:MainFeedSearchMode = MainFeedSearchMode.CurrentLocation
    var searchResultsTableView:UITableView?
    var searchController:UISearchController?
    var currentlyRefreshing = false
    var requiresRefresh = true
    
    // MARK: Outlets
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UISearchResultsUpdating
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
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        filterContentForSearchText(searchController.searchBar.text)
        searchResultsTableView?.reloadData()
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView == tableView){
            if (scrollView.contentOffset.y < -125 && !currentlyRefreshing){
                refreshIndicator.startAnimating()
            }else{
                refreshIndicator.stopAnimating()
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(scrollView == tableView){
            if(refreshIndicator.isAnimating()){
                refreshIndicator.stopAnimating()
                refreshEvents()
            }
        }
    }
 
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleViewController()
        loadSearchController()
        
        // location stuff
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self;
        
        setNeedsStatusBarAppearanceUpdate()
        
        // notification registration
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "handleKeyboardShown:",
            name: UIKeyboardDidShowNotification,
            object: nil)
    }
    
     override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        println("MainFeedViewController -> viewWillAppear")
        super.viewWillAppear(animated)
        
        if(requiresRefresh){
            requiresRefresh = false
            refreshEvents()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkFaceBookToken()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "eventDetailSegue"{
            var destination:EventDetailViewController? = segue.destinationViewController as? EventDetailViewController
            let event = sender as? Event
            destination?.event = sender as? Event
        }else if segue.identifier == "showSettingsSegue"{
            var destination:SettingsTableViewController? = segue.destinationViewController as? SettingsTableViewController
            destination?.mainFeedViewController = self
        }
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
        self.title = ""
        
        let locationFailure:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble getting your location", delegate: nil, cancelButtonTitle: "OK")
        locationFailure.show()
    }
    
    
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if( tableView == searchResultsTableView){
            return self.filteredEvents.count
        }else{
            return events.count
        }
    }
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell:EventTableViewCell? = tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell
        var selectedEvent:Event?
        if(tableView == self.tableView){
            selectedEvent = events[indexPath.row]
        }else if(tableView == searchResultsTableView){
            selectedEvent = filteredEvents[indexPath.row]
            searchController?.active = false
        }
        
        if(selectedEvent != nil){
            if selectedEvent!.detailsLoaded{
                performSegueWithIdentifier("eventDetailSegue", sender: selectedEvent)
            }else{
                cell?.spinner.startAnimating()
                self.tableView.userInteractionEnabled = false
                selectedEvent!.getMoreDetails({ (error:NSError!) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.userInteractionEnabled = true
                        cell?.spinner.stopAnimating()
                        if(error == nil){
                            self.performSegueWithIdentifier("eventDetailSegue", sender: selectedEvent)
                        }else{
                            let alert:UIAlertView = UIAlertView(title: "Sorry", message: "Couldn't get the deets to that event right now", delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                    })
                })
            }
        }
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == self.tableView){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventTableViewCell", forIndexPath: indexPath) as EventTableViewCell
            let event = events[indexPath.row]
            cell.updateForEvent(event)
            cell.eventPhoto?.image = nil
            
            if event.identifier != nil && event.eventImageUrl != nil{
                let imageRequest:NSURLRequest = NSURLRequest(URL: event.eventImageUrl!)
                if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                    cell.eventPhoto?.image = image
                }else{
                    event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                        if(image != nil && error == nil){
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell{
                                cellToUpdate.eventPhoto?.image = image
                            }
                        }
                    })
                }
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("filteredEventCell", forIndexPath: indexPath) as SearchResultsTableCell
            let event:Event = self.filteredEvents[indexPath.row]
            cell.updateForEvent(event)
            return cell
        }
    }
    
    // MARK: - Action
    @IBAction func settingsTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettingsSegue", sender: sender)
    }
    
    // MARK: Private
    func refreshEvents(){
        // if customCity is set in user defaults, user set a default city to search for events
        let search:String? = NSUserDefaults.standardUserDefaults().stringForKey("customCity")
        if(search != nil && countElements(search!) > 0){
            println("Custom search city is set as: " + search!)
            searchMode = MainFeedSearchMode.CustomCity
            currentCity = search
            refreshEventsForCurrentCity()
        }else{
            println("Custom search city not set, using location manager")
            searchMode = MainFeedSearchMode.CurrentLocation
            currentCity = ""
            self.title = "Updating Location..."
            locationManager.startUpdatingLocation()
        }
    }
    
    func checkFaceBookToken(){
        let currentState:FBSessionState = FBSession.activeSession().state
        
        // don't do anything if session is open
        if( currentState == FBSessionState.Open ||
            currentState == FBSessionState.OpenTokenExtended){
                return;
        }else if( currentState == FBSessionState.CreatedTokenLoaded){
            FBSession.openActiveSessionWithAllowLoginUI(false)
            
            FBRequestConnection.startForMeWithCompletionHandler({ (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                if (error == nil){
                    if let resultDictionary:NSDictionary? = result as? NSDictionary{
                        AppDelegate.sharedInstance().fbGraphUserObjectId = resultDictionary!["id"] as? String
                    }
                }
            })
        }else{
            navigationController?.performSegueWithIdentifier("presentFacebookLogin", sender: self)
        }
    }
    
    func refreshEventsForCurrentCity(){
        currentlyRefreshing = true
        println("Refreshing events for: " + currentCity!)
        self.title = "Loading..."
        Event.loadEventsForCity(currentCity!, completion: {(events:[Event]!, error:NSError!) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.title = self.currentCity
                
                // check response
                if(error != nil){
                    let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                    errorAlert.show()
                }else if(events.count == 0){
                    let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                    noEventAlert.show()
                }else{
                    self.events = events
                    self.tableView.reloadData()
                }
                
                self.currentlyRefreshing = false
            })
        })
    }
    
    func loadSearchController()
    {
        // setting up the view controller handling results from the search bar
        
        var searchVC:UIViewController = UIViewController()
        let overlayView = UIVisualEffectView(effect: UIBlurEffect(style:UIBlurEffectStyle.Dark)) as UIVisualEffectView
        searchVC.view.addSubview(overlayView)
        overlayView.constrainToSuperViewEdges()
        
        var tbvc:UITableViewController = UITableViewController(style: UITableViewStyle.Plain)
        tbvc.tableView.delegate = self
        tbvc.tableView.dataSource = self
        tbvc.tableView.backgroundColor = UIColor.clearColor()
        tbvc.tableView.rowHeight = UITableViewAutomaticDimension
        
        searchVC.view.addSubview(tbvc.tableView)
        tbvc.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 70.0))
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        searchVC.view.addConstraint(NSLayoutConstraint(item: tbvc.tableView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: searchVC.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
    
        searchResultsTableView = tbvc.tableView
        
        self.searchController = UISearchController(searchResultsController: searchVC)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.searchBar.barStyle = UIBarStyle.Black
        self.searchController?.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.searchController?.searchBar.tintColor = UIColor.whiteColor()
        self.searchController?.searchBar.placeholder = "Filter Dance Events"
        
        self.searchController?.searchBar.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.searchController!.searchBar.frame.size.width, height: 44))
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.searchController?.dimsBackgroundDuringPresentation = true
        
        tbvc.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tbvc.tableView.separatorColor = UIColor.whiteColor()
        
        tbvc.tableView.registerClass(SearchResultsTableCell.classForCoder(), forCellReuseIdentifier: "filteredEventCell")
    }
    
    func styleViewController()
    {
        self.view.backgroundColor = UIColor(red: 119.0/255.0, green: 120.0/255.0, blue: 124.0/255.0, alpha: 1)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style: UIBarButtonItemStyle.Plain, target: nil, action:nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:FontFactory.navigationTitleFont()]
        
        tableView.backgroundView = UIView()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.estimatedRowHeight = estimatedEventRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
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
}
