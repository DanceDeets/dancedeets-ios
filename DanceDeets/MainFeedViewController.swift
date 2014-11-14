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

class MainFeedViewController:UIViewController,CLLocationManagerDelegate,UISearchResultsUpdating, UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate, EventTableViewCellDelegate {

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
            return event.title?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
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
        if segue.identifier == "showEventSegue"{
            var destination:EventDetailTableViewController? = segue.destinationViewController as?EventDetailTableViewController
            destination?.event = sender as? Event
        }else if segue.identifier == "eventDetailSegue"{
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
        if(tableView == self.tableView){
            let selectedEvent:Event = events[indexPath.row]
            if selectedEvent.detailsLoaded{
                performSegueWithIdentifier("showEventSegue", sender: selectedEvent)
            }else{
                cell?.spinner.startAnimating()
                selectedEvent.getMoreDetails({ (error:NSError!) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        cell?.spinner.stopAnimating()
                        if(error == nil){
                            self.performSegueWithIdentifier("showEventSegue", sender: selectedEvent)
                        }else{
                            let alert:UIAlertView = UIAlertView(title: "Sorry", message: "Couldn't get the deets to that event right now", delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        }
                    })
                })
            }
        }else if(tableView == searchResultsTableView){
            let selectedEvent:Event = filteredEvents[indexPath.row]
            self.searchController?.active = false
            performSegueWithIdentifier("showEventSegue", sender: selectedEvent)
        }
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == self.tableView){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventTableViewCell", forIndexPath: indexPath) as EventTableViewCell
            let event = events[indexPath.row]
            cell.delegate = self
            cell.updateForEvent(event)
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            
            if event.identifier != nil && event.eventImageUrl != nil{
                let imageRequest:NSURLRequest = NSURLRequest(URL: event.eventImageUrl!)
                if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                    cell.eventPhoto?.image = image
                }else{
                    cell.eventPhoto?.image = nil

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
            let cell = tableView.dequeueReusableCellWithIdentifier("filteredEventCell", forIndexPath: indexPath) as UITableViewCell
            let event:Event = self.filteredEvents[indexPath.row]
            cell.textLabel.text = event.title
            return cell
        }
    }
    
    // MARK: - EventTableViewCellDelegate
    func facebookButtonTapped(sender: Event!) {
        var linkparams:FBLinkShareParams = FBLinkShareParams()
        
        if( FBDialogs.canPresentShareDialogWithParams(linkparams)){
            FBDialogs.presentShareDialogWithLink(sender.eventImageUrl, name: sender.title, caption: "Check out this event I found on Dance Deets!", description: "", picture: nil, clientState: nil, handler: { (call:FBAppCall!, clientState:[NSObject : AnyObject]!, error:NSError!) -> Void in
                if(error != nil){
                    println("Error with share dialog")
                }else{
                    println("success")
                }
            })
        }else{
            // TODO test this when I have real links, with facebook uninstalled
            var shareDictionary:NSMutableDictionary = NSMutableDictionary()
            shareDictionary.setObject(sender.title!, forKey: "name")
            shareDictionary.setObject(sender.eventImageUrl!.absoluteString!, forKey: "link")
            let caption:NSString = "Check out this event I found on Dance Deets!"
            shareDictionary.setObject(caption, forKey:"caption")
            
            FBWebDialogs.presentFeedDialogModallyWithSession(nil, parameters: shareDictionary, handler: { (fbresult:FBWebDialogResult, url:NSURL!, error:NSError!) -> Void in
                if(error != nil){
                    println("Error with feed dialog")
                }else{
                    println("Success with feed dialog")
                }
            })
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
        var tbvc:UITableViewController = UITableViewController(style: UITableViewStyle.Plain)
        searchResultsTableView = tbvc.tableView
        searchResultsTableView?.backgroundColor = UIColor.clearColor()
        tbvc.tableView.delegate = self
        tbvc.tableView.dataSource = self
        
        self.searchController = UISearchController(searchResultsController: tbvc)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.searchBar.barStyle = UIBarStyle.Black
        self.searchController?.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        self.searchController?.searchBar.tintColor = UIColor.whiteColor()
        self.searchController?.searchBar.placeholder = "Search Dance Events"
        
        self.searchController?.searchBar.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.searchController!.searchBar.frame.size.width, height: 44))
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.searchController?.dimsBackgroundDuringPresentation = true
        self.searchController?.hidesNavigationBarDuringPresentation = false
        
        tbvc.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "filteredEventCell")
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

    func loadSearchDisplayController()
    {
        searchResultsTableView = self.searchDisplayController?.searchResultsTableView
        searchResultsTableView?.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "filteredEventCell")
        searchResultsTableView?.dataSource = self;
        searchResultsTableView?.delegate = self;
    }
}
