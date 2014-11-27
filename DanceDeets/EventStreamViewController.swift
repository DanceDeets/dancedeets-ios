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

class EventStreamViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    enum SearchMode{
        case CurrentLocation
        case CustomCity
    }
    
    let COLLECTION_VIEW_TOP_MARGIN:CGFloat = 70.0
    var events:[Event] = []
    var currentCity:String? = String()
    var searchMode:SearchMode = SearchMode.CurrentLocation
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    var requiresRefresh = true
    
    // MARK: Outlets
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadViewController()
        
        eventCollectionView.delegate = self
        eventCollectionView.dataSource = self
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
        
        if selectedEvent.detailsLoaded{
            performSegueWithIdentifier("eventDetailSegue", sender: selectedEvent)
        }else{
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.eventCollectionView.userInteractionEnabled = false
            selectedEvent.getMoreDetails({ (error:NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                dispatch_async(dispatch_get_main_queue(), {
                    self.eventCollectionView.userInteractionEnabled = true
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
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return events.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
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
    func loadViewController()
    {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        navigationTitle.textColor = UIColor.whiteColor()
        navigationTitle.font = FontFactory.navigationTitleFont()
        navigationTitle.text = "NEW YORK"
        
        eventCollectionView.layoutIfNeeded()
        let flowLayout:UICollectionViewFlowLayout? = eventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.sectionInset = UIEdgeInsetsZero
        flowLayout?.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height - COLLECTION_VIEW_TOP_MARGIN)
        flowLayout?.minimumInteritemSpacing = 0.0
        
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
        self.navigationTitle.text = "LOADING EVENTS"
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
    
}
