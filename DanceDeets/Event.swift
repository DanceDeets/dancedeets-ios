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
    let starTime:NSDate?
    let endTime:NSDate?
    let keywords:[String]?
    let title:NSString?
    let location:NSString?
    let identifier:NSString?
    
    
    init(dictionary:NSDictionary){
        
    }
    
    public class func loadEventsForCity(city:String, completion: (([Event]!, NSError!)->Void)) -> Void
    {
        var cityString:String? = city.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlString = "http://www.dancedeets.com/events/feed?format=json&distance=10&min_attendees=0&distance_units=miles&location=" + cityString!
        let url = NSURL(string:urlString)
        
        var session = NSURLSession.sharedSession()
        var task:NSURLSessionTask = session.dataTaskWithURL(url, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            if(error != nil){
                completion([], error)
          
            }else{
                var jsonError:NSError?
                var json:NSArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as NSArray
                if (jsonError != nil) {
                    completion([], jsonError)
                }
                else {
                    var eventList:[Event] = []
                    for item in json{
                        if let eventDictionary = item as? NSDictionary{
                            let newEvent:Event? = Event(dictionary: eventDictionary)
                            if newEvent != nil{
                                eventList.append(newEvent!)
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