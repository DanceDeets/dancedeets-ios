//
//  EventFeedTableViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import CoreLocation

class EventFeedTableViewController: UITableViewController,CLLocationManagerDelegate {
    var events:[Event] = []
    var currentCity:String? = String()
    let estimatedEventRowHeight:CGFloat = 400
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    
    // event identifier -> image
    var imageCache = [String : UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.styleTableViewController()
        self.tableView.delegate = self
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.darkGrayColor()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: "refreshEventsForCurrentLocation", forControlEvents: UIControlEvents.ValueChanged)
        var backGroundViewZ = tableView.backgroundView?.layer.zPosition
        self.refreshControl?.layer.zPosition = backGroundViewZ! + 1
        
        // location stuff
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self;
        locationManager.startUpdatingLocation()
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
    
    func refreshEventsForCurrentLocation()
    {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        
        let locationObject:CLLocation = locations.first as CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            let placemark:CLPlacemark = placemarks.first as CLPlacemark
            self.currentCity = placemark.locality
            self.refreshEventsForCity()
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        let locationFailure:UIAlertView = UIAlertView(title: "Sorry", message: "Couldn't get your location at the moment. Try again in a moment.", delegate: nil, cancelButtonTitle: "OK")
        locationFailure.show()
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    // MARK: - Private
    func refreshEventsForCity(){
        
        Event.loadEventsForCity(currentCity!, completion: {(events:[Event]!, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
    }


}
