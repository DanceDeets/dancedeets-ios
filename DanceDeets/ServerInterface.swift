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

    var fetchAddress:FetchAddress?

    // MARK: Common Code
    static let baseUrl:String = "http://www.dancedeets.com/api/v1.1/"

    class func getApiUrl(path: String, withArgs args: [String: String]=[:]) -> NSURL {
        var fullArgs = args
        // Parameters passed on every request
        fullArgs["client"] = "ios"
        return UrlUtil.getUrl(baseUrl + path, withArgs: fullArgs)
    }

    public class var sharedInstance : ServerInterface{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ServerInterface? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            Static.instance = ServerInterface()
        })
        return Static.instance!
    }

    class func executeJsonRequest(url: NSURL, completion: (NSDictionary?, NSError?) -> Void) {
        let task:NSURLSessionTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error != nil) {
                completion(nil, error)
            } else {
                var json:NSDictionary?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                } catch {
                    json = nil
                }
                if (json != nil) {
                    completion(json, nil)
                } else {
                    completion(nil, error)
                }
            }
        })
        task.resume()
    }

    // MARK: Search
    class func getEventSearchUrl(city:String, eventKeyword:String) -> NSURL{
        let args = [
            "location": city,
            "keywords": eventKeyword,
            "time_period": "UPCOMING",
            ]
        return ServerInterface.getApiUrl("search", withArgs: args)
    }

    public class func searchEvents(location:String, withKeywords keyword:String, completion: ((SearchResults?, NSError?) -> Void)) -> Void
    {
        CLSNSLogv("%@", getVaList(["Search Events: \(location): \(keyword ?? "")"]))
        AnalyticsUtil.track("Search Events", [
            "Location": location,
            "Keywords": keyword ?? "",
            ])
        let url = getEventSearchUrl(location, eventKeyword:keyword)

        executeJsonRequest(url, completion: {(json: NSDictionary?, error: NSError?) -> Void in
            if let realJson = json {
                completion(SearchResults(json: realJson), error)
            } else {
                completion(nil, error)
            }
        })
    }

    // MARK: Event Lookup
    class func getEventUrl(eventId: String) -> NSURL{
        return ServerInterface.getApiUrl("events/\(eventId)")
    }

    public class func getEvent(eventId:String, completion: ((Event?, NSError?) -> Void)) -> Void
    {
        CLSNSLogv("%@", getVaList(["Lookup Event: \(eventId)"]))
        let url = getEventUrl(eventId)

        executeJsonRequest(url, completion: {(json: NSDictionary?, error: NSError?) -> Void in
            if let realJson = json {
                completion(Event(dictionary: realJson), error)
            } else {
                completion(nil, error)
            }
        })
    }

    // MARK: Auth/User Creation
    class func getAuthUrl() -> NSURL {
        return ServerInterface.getApiUrl("auth")
    }

    func updateFacebookToken() {
        fetchAddress = FetchAddress(completionHandler: ServerInterface.addressFoundHandler)
    }
    
    class func addressFoundHandler(optionalPlacemark: CLPlacemark?) {

        var geocodeString:String = ""
        if let placemark = optionalPlacemark {
            CLSNSLogv("%@", getVaList(["ServerInterface.addressFound: placemark"]))
            // set up a display address
            if let lines = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                for line in lines {
                    geocodeString += line
                    geocodeString += " "
                }
            }
        }

        // construct payload
        if let tokenData = FBSDKAccessToken.currentAccessToken() {
            let expiration = tokenData.expirationDate
            let accessToken = tokenData.tokenString
            
            let dateFormatter = Utilities.dateFormatter()
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
                CLSNSLogv("%@", getVaList(["Posted up token with error: \(error)"]))
            })
            task.resume()
        }
    }
}