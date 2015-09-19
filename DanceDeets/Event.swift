//
//  Event.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

public class Event: NSObject {
    var eventImageUrl:NSURL?
    var eventImageWidth:CGFloat?
    var eventImageHeight:CGFloat?
    var eventSmallImageUrl:NSURL?
    var venue:String?
    var shortDescription:String?
    var startTime:NSDate?
    var endTime:NSDate?
    var keywords:[String] = []
    var title:String?
    var id:String?
    var displayTime:String?
    var facebookUrl:NSURL?
    var danceDeetsUrl:NSURL?
    var displayAddress:String = ""
    var geoloc:CLLocation?
    var admins:[EventAdmin] = []
    var placemark:CLPlacemark?
    var attendingCount:Int?
    public var detailsLoaded:Bool = false
    var savedEventId:NSString? // if user saved this event on iOS, this is that identifier
    
    init(dictionary:NSDictionary){
        super.init()
        
        title = dictionary["name"] as? String
        id = dictionary["id"] as? String
        shortDescription = dictionary["description"] as? String
        
        if id != nil && (id!).characters.count > 0 {
            facebookUrl = NSURL(string: "http://www.facebook.com/"+id!)
            danceDeetsUrl = NSURL(string: "http://www.dancedeets.com/events/"+id!)
        }
        
        if let rsvp = dictionary["rsvp"] as? NSDictionary{
            if let attending = rsvp["attending_count"] as? Int{
                self.attendingCount = attending
            }
        }
        
        // admins
        if let admins = dictionary["admins"] as? NSArray{
            for admin in admins{
                if let adminDict = admin as? NSDictionary{
                    let name:String? = admin["name"] as? String
                    let identifier:String? = admin["id"] as? String
                    if name != nil && identifier != nil{
                        let newAdmin = EventAdmin(name:name!, identifier:identifier!)
                        self.admins.append(newAdmin)
                    }
                }
            }
        }
        
        // venue
        if let venue = dictionary["venue"] as? NSDictionary{
            if let geocodeDict = venue["geocode"] as? NSDictionary{
                let lat:CLLocationDegrees = geocodeDict["latitude"] as! CLLocationDegrees
                let long:CLLocationDegrees = geocodeDict["longitude"] as! CLLocationDegrees
                self.geoloc = CLLocation(latitude: lat, longitude: long)
            }
            if let name = venue["name"] as? String{
                self.venue = name
                displayAddress = name
            }
        }
        
        // annotations
        if let annotations = dictionary["annotations"] as? NSDictionary{
            if let danceKeywords = annotations["dance_keywords"] as? [String]{
                self.keywords = danceKeywords
            }
        }
     
        // cover image
        if let coverDictionary = dictionary["cover"] as? NSDictionary{
            if let images = coverDictionary["images"] as? NSArray{
                if images.count > 0{
                    if let firstImage = images[0] as? NSDictionary{
                        if let source = firstImage["source"] as? String{
                            eventImageUrl = NSURL(string:source)
                        }
                        if let height = firstImage["height"] as? CGFloat {
                            eventImageHeight = height
                        }
                        if let width = firstImage["width"] as? CGFloat {
                            eventImageWidth = width
                        }
                    }
                }
            }
        }
        if(eventImageUrl == nil){
            if let picture = dictionary["picture"] as? String{
                eventImageUrl = NSURL(string:picture)
            }
        }
        
        if let picture = dictionary["picture"] as? String{
            eventSmallImageUrl = NSURL(string:picture)
        }
        
        // times
        let dateFormatter:NSDateFormatter  = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        if let startTimeString = dictionary["start_time"] as? String{
            startTime = dateFormatter.dateFromString(startTimeString)
        }
        if let endTimeString = dictionary["end_time"] as? String{
            endTime = dateFormatter.dateFromString(endTimeString)
        }
        
        // date formatting
        let dateFormatterStart:NSDateFormatter  = NSDateFormatter()
        let dateFormatterEnd:NSDateFormatter = NSDateFormatter()
        var dateDisplayString:String  =  String()
        dateFormatterStart.dateFormat = "EEE MMM d  |  ha"
        dateFormatterEnd.dateFormat = "ha"
        if (startTime != nil && endTime != nil){
            // there's a start and end time
            dateDisplayString += dateFormatterStart.stringFromDate(startTime!)
            dateDisplayString += " - "
            dateDisplayString += dateFormatterEnd.stringFromDate(endTime!)
        }else if(startTime != nil){
            // start time
            dateDisplayString += dateFormatterStart.stringFromDate(startTime!)
        }else{
            // check for full day event
            let dateFormatter:NSDateFormatter  = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
            
            if let startTimeString = dictionary["start_time"] as? String{
                startTime = dateFormatter.dateFromString(startTimeString)
                if(startTime != nil){
                    let displayFormatter:NSDateFormatter = NSDateFormatter()
                    displayFormatter.dateFormat = "EEE MMM dd  |  'All Day'"
                    dateDisplayString = displayFormatter.stringFromDate(startTime!)
                }
            }
        }
        displayTime = dateDisplayString.uppercaseString
    }
    
    // Create sharing items for the activity sheet
    public func createSharingItems()->[AnyObject]{
        var sharingItems:[AnyObject] = []
        
        if(title != nil){
            sharingItems.append("Check out this event: " + title!)
        }
        
        if(danceDeetsUrl != nil){
            sharingItems.append(danceDeetsUrl!)
        }
        
        return sharingItems
    }
    
    // Attempts to download the cover image for this event, callbacks on mainthread
    public func downloadCoverImage(completion:((UIImage!,NSError!)->Void)) ->Void
    {
        if(eventImageUrl != nil){
            downloadImage(eventImageUrl!, completion: completion)
        }else{
            completion(nil,nil)
        }
    }
    
    public func downloadSmallImage(completion:((UIImage!,NSError!)->Void)) ->Void
    {
        if(eventSmallImageUrl != nil){
            downloadImage(eventSmallImageUrl!, completion: completion)
        }else{
            completion(nil,nil)
        }
    }
    
    func downloadImage(url:NSURL,completion:((UIImage!,NSError!)->Void)) ->Void
    {
        let imageRequest:NSURLRequest = NSURLRequest(URL: url)
        var downloadTask:NSURLSessionDownloadTask =
        NSURLSession.sharedSession().downloadTaskWithRequest(imageRequest,
            completionHandler: { (location:NSURL?, resp:NSURLResponse?, error:NSError?) -> Void in
                if(error == nil){
                    let data:NSData? = NSData(contentsOfURL: location)
                    if let newImage = UIImage(data: data!, scale: UIScreen.mainScreen().scale){
                        ImageCache.sharedInstance.cacheImageForRequest(newImage, request: imageRequest)
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(newImage,nil)
                        })
                    }else{
                        let error = NSError(domain: "Couldn't create image from data", code: 0, userInfo: nil)
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(nil, error)
                        })
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(nil, error)
                    })
                }
        })
        downloadTask.resume()
        
    }
    
    public class func loadEventsForLocation(location:CLLocation, keyword:String?, completion: (([Event]!, NSError!)->Void)) -> Void
    {
        loadEventsFromUrl(ServerInterface.sharedInstance.getEventSearchUrlByLocation(location, eventKeyword:keyword), completion:completion)
    }
    
    public class func loadEventsForCity(city:String, keyword:String?, completion: (([Event]!, NSError!)->Void)) -> Void
    {
        loadEventsFromUrl(ServerInterface.sharedInstance.getEventSearchUrl(city, eventKeyword:keyword), completion:completion)
    }
    
    public func getMoreDetails(completion: (()->Void)) -> Void
    {
        if(!detailsLoaded){
            detailsLoaded = true
            if(geoloc != nil){
                // currently using Apple's geocoder to reverse geocode the lat/long
                let geocoder:CLGeocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(geoloc, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if placemarks.count > 0{
                            self.placemark = placemarks.first as? CLPlacemark
                            
                            // set up a display address
                            if let lines = self.placemark?.addressDictionary["FormattedAddressLines"] as? [String]{
                                if lines.count >= 2{
                                    self.displayAddress += "\n"
                                    self.displayAddress += lines[0]
                                    self.displayAddress += "\n"
                                    self.displayAddress += lines[1]
                                }
                            }
                        }
                        completion()
                    })
                })
            }else{
                completion()
            }
        }else{
            completion()
        }
    }
    
    public class func loadEventsFromUrl(url:NSURL, completion: (([Event]!, NSError!)->Void)) -> Void
    {
        var task:NSURLSessionTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if(error != nil){
                completion([], error)
            }else{
                var jsonError:NSError?
                let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                var json:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                if (jsonError != nil) {
                    completion([], jsonError)
                }
                else {
                    var eventList:[Event] = []
                    if(json != nil){
                        if let results = json!["results"] as? NSArray{
                            for item in results{
                                if let eventDictionary = item as? NSDictionary{
                                    let newEvent:Event? = Event(dictionary: eventDictionary)
                                    if newEvent != nil{
                                        eventList.append(newEvent!)
                                    }
                                }
                            }
                        }
                    }
                    completion(eventList, nil)
                }
            }
        })
        task.resume()
    }
    
    
    
}