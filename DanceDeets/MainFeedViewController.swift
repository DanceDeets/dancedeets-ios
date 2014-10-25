//
//  MainFeedViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/22/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import CoreLocation

enum MainFeedSearchMode{
    case CurrentLocation
    case CustomCity
}

class MainFeedViewController: UIViewController,CLLocationManagerDelegate,UISearchBarDelegate,UISearchDisplayDelegate ,UITableViewDataSource, UITableViewDelegate {

    var events:[Event] = []
    var filteredEvents:[Event] = []
    var currentCity:String? = String()
    let estimatedEventRowHeight:CGFloat = 600
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    var imageCache = [String : UIImage]()
    var searchMode:MainFeedSearchMode = MainFeedSearchMode.CurrentLocation
    var searchResultsTableView:UITableView?
    
    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: UISearchDisplayDelegate
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        self.filteredEvents = self.events.filter({( event: Event) -> Bool in
            return event.title?.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }
 
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleViewController()
        loadSearchDisplayController()
        
        // location stuff
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self;
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
     override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkFaceBookToken()
        println("MainFeedViewController -> viewWillAppear")
        
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
            locationManager.startUpdatingLocation()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEventSegue"{
            var destination:EventDetailTableViewController? = segue.destinationViewController as?EventDetailTableViewController
            destination?.event = sender as Event?
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        
        let locationObject:CLLocation = locations.first as CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if(placemarks.count > 0){
                let placemark:CLPlacemark = placemarks.first as CLPlacemark
                self.currentCity = placemark.locality
                self.refreshEventsForCurrentCity()
            }else{
                let locationFailure:UIAlertView = UIAlertView(title: "Sorry", message: "Having some trouble figuring out where you are right now!", delegate: nil, cancelButtonTitle: "OK")
                locationFailure.show()
            }
        })
    }
    
    
    // MARK: UITableViewDataSource / UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView{
            return self.filteredEvents.count
        }else{
            return events.count
        }
    }
     func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath)
    {
        var cell:UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell:EventTableViewCell? = tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell
        if(tableView == self.tableView){
            let selectedEvent:Event = events[indexPath.row]
            performSegueWithIdentifier("showEventSegue", sender: selectedEvent)
        }else if(tableView == searchResultsTableView){
            let selectedEvent:Event = filteredEvents[indexPath.row]
            performSegueWithIdentifier("showEventSegue", sender: selectedEvent)
        }
    }
    
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == self.tableView){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventTableViewCell", forIndexPath: indexPath) as EventTableViewCell
            let event = events[indexPath.row]
            cell.updateForEvent(event)
            
            if event.identifier != nil && event.eventImageUrl != nil{
                if let image = imageCache[event.identifier!] {
                    cell.eventPhoto?.image = image
                }else{
                    cell.eventPhoto?.image = nil
                    var imgUrl = event.eventImageUrl!
                    
                    // Download an NSData representation of the image at the URL
                    let request: NSURLRequest = NSURLRequest(URL: imgUrl)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if error == nil {
                            let newImage = UIImage(data: data)
                            
                            // Store the image in to our cache
                            self.imageCache[event.identifier!] = newImage
                            dispatch_async(dispatch_get_main_queue(), {
                                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell{
                                    cellToUpdate.eventPhoto?.image = newImage
                                }
                            })
                        }
                        else {
                            println("Error: \(error.localizedDescription)")
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
    
    // MARK: - Action
    @IBAction func settingsTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettingsSegue", sender: sender)
    }
    
    @IBAction func refreshTapped(sender: AnyObject) {
        refreshEventsForCurrentCity()
    }
    
    // MARK: Private
    func checkFaceBookToken(){
        let currentState:FBSessionState = FBSession.activeSession().state
        
        // don't do anything if session is open
        if( currentState == FBSessionState.Open ||
            currentState == FBSessionState.OpenTokenExtended){
                return;
        }else if( currentState == FBSessionState.CreatedTokenLoaded){
            FBSession.openActiveSessionWithAllowLoginUI(false)
            
               let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            println(appDelegate.facebookGraphUser?.objectID)
            println(appDelegate.facebookGraphUser?.link)
        }else{
            let fbLogin:FaceBookLoginViewController? = storyboard?.instantiateViewControllerWithIdentifier("faceBookLoginViewController") as? FaceBookLoginViewController
            presentViewController(fbLogin!, animated: true, completion: nil)
        }
    }
    
    func refreshEventsForCurrentCity(){
        
        println("Refreshing events for: " + currentCity!)
        self.title = "Loading..."
        Event.loadEventsForCity(currentCity!, completion: {(events:[Event]!, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.title = self.currentCity
                
                // check response
                if(error != nil){
                    let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                    errorAlert.show()
                }else if(events.count == 0){
                    let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in your area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                    noEventAlert.show()
                }else{
                    // success, update the refresh label
                    var formatter = NSDateFormatter()
                    formatter.dateFormat = "MMM d, h:mm a";
                    let string = formatter.stringFromDate(NSDate())
                    let title:String = self.currentCity! + " - Last updated: " + string
                    
                    var attributedString:NSMutableAttributedString = NSMutableAttributedString(string: title)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range:NSMakeRange(0, countElements(title)))
                    
                    // re assing events and reload table
                    self.events = events
                    self.tableView.reloadData()
                }
                
            })
        })
    }
    
    func styleViewController()
    {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style: UIBarButtonItemStyle.Plain, target: nil, action:nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:FontFactory.navigationTitleFont()]
        
        //tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
        tableView.backgroundColor = UIColor(red: 119.0/255.0, green: 120.0/255.0, blue: 124.0/255.0, alpha: 1)
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
