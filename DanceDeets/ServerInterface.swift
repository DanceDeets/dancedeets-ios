//
//  ServerInterface.swift
//  DanceDeets
//
//  Created by David Xiang on 12/13/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import CoreLocation


/* Any kind of interfacing with the back end should go in here */
class ServerInterface : NSObject, CLLocationManagerDelegate {
    
    // swift doesn't support class constant variables yet, but you can do it in a struct
    class var sharedInstance : ServerInterface{
        struct Static{
            static var onceToken : dispatch_once_t = 0
            static var instance : ServerInterface? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = ServerInterface()
            Static.instance?.locationManager.requestWhenInUseAuthorization()
            Static.instance?.locationManager.delegate = Static.instance
    
        })
        return Static.instance!
    }
    
    
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    
    func updateFacebookToken(){
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        
        let locationObject:CLLocation = locations.first as CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if( placemarks != nil && placemarks.count > 0){
                let placemark:CLPlacemark = placemarks.first as CLPlacemark
                var geocodeString:String = ""
                
                // set up a display address
                if let lines = placemark.addressDictionary["FormattedAddressLines"] as? [String]{
                    for line in lines{
                        geocodeString += line
                        geocodeString += " "
                    }
                }
                
                // construct payload
                let tokenData = FBSession.activeSession().accessTokenData
                let expiration = tokenData.expirationDate
                let accessToken = tokenData.accessToken
                
                let dateFormatter:NSDateFormatter  = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
                dateFormatter.timeZone = NSTimeZone.systemTimeZone()
                
                var session = NSURLSession.sharedSession()
                var urlString = "http://www.dancedeets.com/api/auth"
                let url = NSURL(string:urlString)
                var urlRequest = NSMutableURLRequest(URL: url!)
                urlRequest.HTTPMethod = "POST"
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let params = NSMutableDictionary()
                params["client"] = "ios"
                params["location"] = geocodeString
                params["access_token"] = accessToken
                params["access_token_expires"] = dateFormatter.stringFromDate(expiration)
                let postData = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
                urlRequest.HTTPBody = postData
                
                // post it up
                let task = session.dataTaskWithRequest(urlRequest, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
                    println("Posted up token")
                    println(response)
                })
                task.resume()
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        println("Couldn't update location")
       
    }
    
}