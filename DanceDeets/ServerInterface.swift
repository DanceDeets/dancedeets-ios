//
//  ServerInterface.swift
//  DanceDeets
//
//  Created by David Xiang on 12/13/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import CoreLocation

public class ServerInterface : NSObject, CLLocationManagerDelegate {

    // MARK: Static URL Construction Methods
    static let urlArgCharacterSet = ServerInterface.getUrlArgCharacterSet()
    static let baseUrl:String = "http://www.dancedeets.com/api/v1.1"
    
    class func getUrlArgCharacterSet() -> NSCharacterSet {
        let characterSet:NSMutableCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        characterSet.addCharactersInString("&=")
        let realCharacterSet:NSCharacterSet = characterSet.copy() as! NSCharacterSet
        return realCharacterSet
    }

    class func getApiUrl(path: String, withArgs args: [String: String]=[:]) -> NSURL {
        var fullArgs = args
        // Parameters passed on every request
        fullArgs["client"] = "ios"
        let stringArgs = fullArgs.map(
            {(key: String, value: String) -> String in
                return key.stringByAddingPercentEncodingWithAllowedCharacters(ServerInterface.urlArgCharacterSet)!
                    + "="
                    + value.stringByAddingPercentEncodingWithAllowedCharacters(ServerInterface.urlArgCharacterSet)!
            }
        )
        let url = baseUrl + path + "?" + stringArgs.joinWithSeparator("&")
        return NSURL(string: url)!
    }

    // MARK: Shared Instance Setup
    public class var sharedInstance : ServerInterface{
        struct Static {
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

    // MARK: Regular Methods
    let locationManager:CLLocationManager  = CLLocationManager()
    let geocoder:CLGeocoder = CLGeocoder()
    
    func getAuthUrl() -> NSURL {
        return ServerInterface.getApiUrl("auth")
    }
    
    func getEventSearchUrl(city:String, eventKeyword:String?) -> NSURL{
        var args = [
            "location": city,
            "time_period": "UPCOMING",
        ]
        if eventKeyword != nil {
            args["keywords"] = eventKeyword
        }
        return ServerInterface.getApiUrl("/search", withArgs: args)
    }
    
    func getEventSearchUrlByLocation(location: CLLocation, eventKeyword: String?) -> NSURL {
        var args = [
            "location": "\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "time_period": "UPCOMING",
        ]
        if eventKeyword != nil {
            args["keywords"] = eventKeyword
        }
        return ServerInterface.getApiUrl("/search", withArgs: args)
    }
    
    func updateFacebookToken() {
        locationManager.startUpdatingLocation()
    }
    
    func completionHandler(placemarks: [CLPlacemark]?, error: NSError?) {
        if (placemarks != nil && placemarks!.count > 0) {
            let placemark:CLPlacemark = placemarks!.first!
            var geocodeString:String = ""
            
            // set up a display address
            if let lines = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                for line in lines {
                    geocodeString += line
                    geocodeString += " "
                }
            }
            
            // construct payload
            FBSDKAccessToken.currentAccessToken()
            if let tokenData = FBSDKAccessToken.currentAccessToken() {
                let expiration = tokenData.expirationDate
                let accessToken = tokenData.tokenString
                
                let dateFormatter:NSDateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
                dateFormatter.timeZone = NSTimeZone.systemTimeZone()
                
                let urlRequest = NSMutableURLRequest(URL: self.getAuthUrl())
                urlRequest.HTTPMethod = "POST"
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let params = NSMutableDictionary()
                params["client"] = "ios"
                params["location"] = geocodeString
                params["access_token"] = accessToken
                params["access_token_expires"] = dateFormatter.stringFromDate(expiration)
                let postData = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
                urlRequest.HTTPBody = postData
                
                // post it up
                let task = NSURLSession.sharedSession().dataTaskWithRequest(urlRequest, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    print("Posted up token with error: \(error)")
                })
                task.resume()
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        locationManager.stopUpdatingLocation()
        
        let locationObject:CLLocation = locations.first as CLLocation!
        geocoder.reverseGeocodeLocation(locationObject, completionHandler: completionHandler)
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
    }
}