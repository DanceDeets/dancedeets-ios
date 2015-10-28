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
    var event: NSDictionary?
    var eventImageUrl:NSURL?
    var eventImageWidth:CGFloat?
    var eventImageHeight:CGFloat?
    var eventSmallImageUrl:NSURL?
    var venue:Venue?
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
    var attendingCount:Int?
    var categories:[String] = []
    
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
                if let _ = admin as? NSDictionary{
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
        self.venue = Venue(dictionary["venue"] as! NSDictionary)
        if self.venue?.latLong != nil {
            self.geoloc = CLLocation(
                latitude: self.venue!.latLong!.0,
                longitude: self.venue!.latLong!.1
            )
        }
        let displayAddressComponents:[String?] = [self.venue?.name, self.venue?.street, self.venue?.cityStateZip()]
        displayAddress = displayAddressComponents.filter({$0 != nil}).map({$0!}).joinWithSeparator("\n")
        
        // annotations
        if let annotations = dictionary["annotations"] as? NSDictionary{
            if let danceKeywords = annotations["dance_keywords"] as? [String] {
                self.keywords = danceKeywords
            }
            if let categories = annotations["categories"] as? [String] {
                self.categories = categories
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
        let datetimeImporter = Utilities.dateFormatter()
        datetimeImporter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        if let startTimeString = dictionary["start_time"] as? String{
            startTime = datetimeImporter.dateFromString(startTimeString)
        }
        if let endTimeString = dictionary["end_time"] as? String{
            endTime = datetimeImporter.dateFromString(endTimeString)
        }
        
        // date formatting
        let dateFormatterStart = NSDateFormatter()
        var dateDisplayString:String = String()
        dateFormatterStart.dateFormat = "EEE MMM dd  |  H:mm"
        if (startTime != nil && endTime != nil) {
            let dateFormatterEnd = NSDateFormatter()
            dateFormatterEnd.dateFormat = "H:mm"

            // there's a start and end time
            dateDisplayString += dateFormatterStart.stringFromDate(startTime!)
            dateDisplayString += " - "
            dateDisplayString += dateFormatterEnd.stringFromDate(endTime!)
        } else if (startTime != nil) {
            // start time
            dateDisplayString += dateFormatterStart.stringFromDate(startTime!)
        } else {
            // check for full day event
            let dateImporter = Utilities.dateFormatter()
            dateImporter.dateFormat = "yyyy'-'MM'-'dd"
            if let startTimeString = dictionary["start_time"] as? String{
                startTime = dateImporter.dateFromString(startTimeString)
                if (startTime != nil) {
                    let displayFormatter = NSDateFormatter()
                    displayFormatter.dateFormat = "EEE MMM dd"
                    dateDisplayString = displayFormatter.stringFromDate(startTime!)
                }
            }
        }
        displayTime = dateDisplayString
    }
    
    // Create sharing items for the activity sheet
    public func createSharingItems()->[AnyObject] {
        var sharingItems:[AnyObject] = []
        
        if (title != nil) {
            sharingItems.append(title!)
        }
        
        if (danceDeetsUrl != nil) {
            sharingItems.append(danceDeetsUrl!)
        }
        
        return sharingItems
    }
    
    // Attempts to download the cover image for this event, callbacks on mainthread
    public func downloadCoverImage(completion:((UIImage!,NSError!)->Void)) {
        if (eventImageUrl != nil) {
            downloadImage(eventImageUrl!, completion: completion)
        } else {
            completion(nil,nil)
        }
    }
    
    public func downloadSmallImage(completion:((UIImage!,NSError!)->Void))
    {
        if(eventSmallImageUrl != nil){
            downloadImage(eventSmallImageUrl!, completion: completion)
        }else{
            completion(nil,nil)
        }
    }
    
    func downloadImage(url:NSURL, completion:((UIImage!,NSError!)->Void))
    {
        let imageRequest:NSURLRequest = NSURLRequest(URL: url)
        let downloadTask:NSURLSessionDownloadTask =
        NSURLSession.sharedSession().downloadTaskWithRequest(imageRequest,
            completionHandler: { (location:NSURL?, resp:NSURLResponse?, error:NSError?) -> Void in
                if (error == nil) {
                    let data:NSData? = NSData(contentsOfURL: location!)
                    if let newImage = UIImage(data: data!, scale: UIScreen.mainScreen().scale){
                        ImageCache.sharedInstance.cacheImageForRequest(newImage, request: imageRequest)
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(newImage,nil)
                        })
                    } else {
                        let error = NSError(domain: "Couldn't create image from data", code: 0, userInfo: nil)
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(nil, error)
                        })
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(nil, error)
                    })
                }
        })
        downloadTask.resume()
        
    }
    
    public class func loadEventsForLocation(location:String, withKeywords keyword:String, completion: (([Event]!, NSError!)->Void)) -> Void
    {
        AnalyticsUtil.track("Search Events", [
            "Location": location,
            "Keywords": keyword ?? "",
            ])
        loadEventsFromUrl(ServerInterface.sharedInstance.getEventSearchUrl(location, eventKeyword:keyword), completion:completion)
    }
    
    public class func loadEventsFromUrl(url:NSURL, completion: (([Event]!, NSError!)->Void)) -> Void
    {
        let task:NSURLSessionTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if (error != nil) {
                completion([], error)
            } else {
                var json:NSDictionary?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                } catch {
                    json = nil
                }
                if (json == nil) {
                    completion([], error)
                }
                else {
                    var eventList:[Event] = []
                    if (json != nil) {
                        if let results = json!["results"] as? NSArray {
                            for item in results{
                                if let eventDictionary = item as? NSDictionary {
                                    let newEvent:Event? = Event(dictionary: eventDictionary)
                                    if newEvent != nil {
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