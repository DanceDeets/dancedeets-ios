//
//  Event.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import UIKit

public class Event: NSObject {
    let eventImageUrl:NSURL?
    let eventImage:UIImage?
    let venue:NSString?
    let shortDescription:NSString?
    let startTime:NSDate?
    let endTime:NSDate?
    let keywords:[String]?
    let tagString:NSString?
    let title:NSString?
    let location:NSString?
    let identifier:NSString?
    let displayTime:NSString?
    
    
    init(dictionary:NSDictionary){
        super.init()
        venue = dictionary["city"] as? String
        title = dictionary["title"] as? String
        identifier = dictionary["id"] as? String
        shortDescription = dictionary["description"] as? String
        
        let coverUrlKey:NSString = "cover_url"
        let coverDictionary = dictionary[coverUrlKey] as? NSDictionary
        
        if coverDictionary != nil{
            if let coverImageUrl = coverDictionary!["source"] as? String {
                eventImageUrl = NSURL(string: coverImageUrl)
            }
        }
        
        let dateFormatter:NSDateFormatter  = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        if let startTimeString = dictionary["start_time"] as? String{
            startTime = dateFormatter.dateFromString(startTimeString)
        }
        if let endTimeString = dictionary["end_time"] as? String{
            endTime = dateFormatter.dateFromString(endTimeString)
        }
        
        // Set up display time
        var dateFormatterStart:NSDateFormatter  = NSDateFormatter()
        var dateFormatterEnd:NSDateFormatter = NSDateFormatter()
        var dateDisplayString:String  = String()
        dateFormatterStart.dateFormat = "MMM dd 'at' h:mm a"
        dateFormatterEnd.dateFormat = "h:mm a"
        if (startTime != nil && endTime != nil){
            dateDisplayString += dateFormatterStart.stringFromDate(startTime!)
            dateDisplayString += " till "
            dateDisplayString += dateFormatterEnd.stringFromDate(endTime!)
        } else if(startTime != nil){
            dateDisplayString += dateFormatterStart.stringFromDate(startTime!)
        }else{
            dateDisplayString = "Unknown Time"
        }
        displayTime = dateDisplayString 
        
        location = dictionary["location"] as? String
        
        if let keywordString = dictionary["keywords"] as? String{
            tagString = keywordString
            keywords = keywordString.componentsSeparatedByString(",")
        }
    }
    
    public class func loadEventsForCity(city:String, completion: (([Event]!, NSError!)->Void)) -> Void
    {
        var cityString:String? = city.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlString = "http://www.dancedeets.com/events/feed?format=json&distance=10&min_attendees=0&distance_units=miles&location=" + cityString!
        let url = NSURL(string:urlString)
        
        var session = NSURLSession.sharedSession()
        var task:NSURLSessionTask = session.dataTaskWithURL(url!, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            if(error != nil){
                completion([], error)
            }else{
                var jsonError:NSError?
                var json:NSArray? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSArray
                if (jsonError != nil) {
                    completion([], nil)
                }
                else {
                    var eventList:[Event] = []
                    if(json != nil && json?.count > 0){
                        for item in json!{
                            if let eventDictionary = item as? NSDictionary{
                                let newEvent:Event? = Event(dictionary: eventDictionary)
                                if newEvent != nil{
                                    eventList.append(newEvent!)
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