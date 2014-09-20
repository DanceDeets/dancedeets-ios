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
    
    public class func loadEventsForCity(city:String, completion: (([Event]!, NSError!)->Void)?) -> Void
    {
        let url = NSURL(string:"http://97.88.225.91:5309/scheck")
        var session = NSURLSession.sharedSession()
        var task:NSURLSessionTask = session.dataTaskWithURL(url, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            
            println("Got Data")
            if(completion != nil){
                completion!([], error)
            }
            
        })
        task.resume()
    
    }
    
}