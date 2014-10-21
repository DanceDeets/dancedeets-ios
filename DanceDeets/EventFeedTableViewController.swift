//
//  EventFeedTableViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import CoreLocation

enum EventFeedSearchMode{
    case CurrentLocation
    case CustomCity
}

class EventFeedTableViewController: UITableViewController,CLLocationManagerDelegate {
    
    var events:[Event] = []
    var currentCity:String? = String()
    let estimatedEventRowHeight:CGFloat = 400
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    var imageCache = [String : UIImage]()
    var searchMode:EventFeedSearchMode = EventFeedSearchMode.CurrentLocation  

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation styling
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style: UIBarButtonItemStyle.Plain, target: nil, action:nil)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:FontFactory.navigationTitleFont()]

        // table view styling
        styleTableViewController()
        
        // refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.darkGrayColor()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: "refreshControlHandler", forControlEvents: UIControlEvents.ValueChanged)
        var backGroundViewZ = tableView.backgroundView?.layer.zPosition
        self.refreshControl?.layer.zPosition = backGroundViewZ! + 1
        
        // location stuff
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("EventFeedTableViewController -> viewWillAppear")
        
        // always go back to top when view re-appears
        self.tableView.setContentOffset(CGPointMake(0, 0), animated: false)
        
        // if customCity is set in user defaults, user set a default city to search for events
        let search:String? = NSUserDefaults.standardUserDefaults().stringForKey("customCity")
        if(search != nil && countElements(search!) > 0){
            println("Custom search city is set as: " + search!)
            searchMode = EventFeedSearchMode.CustomCity
            currentCity = search
            refreshEventsForCurrentCity()
        }else{
            println("Custom search city not set, using location manager")
            searchMode = EventFeedSearchMode.CurrentLocation
            currentCity = ""
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkFaceBookToken()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEventSegue"{
            var destination:EventDetailTableViewController? = segue.destinationViewController as?EventDetailTableViewController
            destination?.event = sender as Event?
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        let locationFailure:UIAlertView = UIAlertView(title: "Sorry! Couldn't get your location", message: "Set your city in the settings for now", delegate: nil, cancelButtonTitle: "OK")
        locationFailure.show()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedEvent:Event = events[indexPath.row]
        performSegueWithIdentifier("showEventSegue", sender: selectedEvent)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    }
    
    
    // MARK: - Action
    @IBAction func settingsTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("showSettingsSegue", sender: sender)
    }
    
    // MARK: - Private
    func refreshControlHandler()
    {
        if(searchMode == EventFeedSearchMode.CurrentLocation ){
            locationManager.startUpdatingLocation()
        }else{
            refreshEventsForCurrentCity()
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
                // stop refresh control first
                self.refreshControl?.endRefreshing()
                
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
                    let title:String = self.currentCity! + " - Last update: " + string
                    
                    var attributedString:NSMutableAttributedString = NSMutableAttributedString(string: title)
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range:NSMakeRange(0, countElements(title)))
                    
                    self.refreshControl?.attributedTitle = attributedString
                    
                    // re assing events and reload table
                    self.events = events
                    self.tableView.reloadData()
                }
                
            })
        })
 
    }
    
    func styleTableViewController(){
        tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
        tableView.estimatedRowHeight = estimatedEventRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        tableView.tableHeaderView = UIView(frame:CGRectMake(0, 0, self.tableView.frame.size.width, CGFloat.min))
    }


}
