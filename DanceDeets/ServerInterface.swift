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
public class ServerInterface : NSObject, CLLocationManagerDelegate {
    
    // swift doesn't support class constant variables yet, but you can do it in a struct
    public class var sharedInstance : ServerInterface{
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
    
    let baseUrl:String = "http://www.dancedeets.com/api/v1.0"
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    
    func getAuthUrl() -> NSURL {
        return NSURL(string: baseUrl + "/auth")!
    }
    
    func getEventSearchUrl(city:String) -> NSURL{
        var cityString:String = city.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        return NSURL(string: baseUrl + "/search?location=" + cityString)!
    }
    
    func getEventSearchUrlByLocation(location:CLLocation)->NSURL{
        let coordinate = location.coordinate
        return NSURL(string: baseUrl + "/search?location=\(coordinate.latitude),\(coordinate.longitude)")!
    }
    
    func updateFacebookToken(){
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        locationManager.stopUpdatingLocation()
        
        let locationObject:CLLocation = locations.first as! CLLocation
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if( placemarks != nil && placemarks.count > 0){
                let placemark:CLPlacemark = placemarks.first as! CLPlacemark
                var geocodeString:String = ""
                
                // set up a display address
                if let lines = placemark.addressDictionary["FormattedAddressLines"] as? [String]{
                    for line in lines{
                        geocodeString += line
                        geocodeString += " "
                    }
                }
                
                // construct payload
                if let tokenData = FBSession.activeSession().accessTokenData{
                    let expiration = tokenData.expirationDate
                    let accessToken = tokenData.accessToken
                    
                    let dateFormatter:NSDateFormatter  = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
                    dateFormatter.timeZone = NSTimeZone.systemTimeZone()
                    
                    var urlRequest = NSMutableURLRequest(URL: self.getAuthUrl())
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
                    let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
                        println("Posted up token with error: \(error)")
                    })
                    task.resume()
                }
            }
        })
    }
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        println("Couldn't update location")
    }
    

    
}