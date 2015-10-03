//
//  GooglePlaceAPI.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

public class GooglePlaceAPI{
    
    public class func apiKey() -> String{
        return "AIzaSyCIaKGVhI2vD9rA7oGLltgHcUw7TuBPzBc"
    }
    
    public class func autoSuggestCity(query:String,completion:((autosuggests:[String]!,error:NSError!)->Void)) ->Void
    {
        let baseUrl:String = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        let url = UrlUtil.getUrl(baseUrl, withArgs:[
            "input": query,
            "types": "(regions)",
            "key": apiKey(),
        ])
        let session = NSURLSession.sharedSession()
        let task:NSURLSessionTask = session.dataTaskWithURL(url, completionHandler: { (data:NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error != nil) {
                completion(autosuggests: [], error: error)
            } else {
                let json:NSDictionary?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                } catch {
                    json = nil
                }
                if (json == nil) {
                    completion(autosuggests: [], error: error)
                } else {
                    var autoSuggestions:[String] = []
                    if let predictions = json!["predictions"] as? NSArray {
                        for prediction in predictions {
                            if let predictionDict = prediction as? NSDictionary {
                                if let terms = predictionDict["description"] as? String {
                                    if (terms.characters.count > 0) {
                                        autoSuggestions.append(terms)
                                    }
                                }
                            }
                        }
                    }
                    completion(autosuggests: autoSuggestions, error: nil)
                }
            }
        })
        task.resume()
    }
}
