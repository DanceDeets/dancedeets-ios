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
        let requestUrlString:String = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input="+query+"&types=(cities)&key=" + apiKey()
        if let url:NSURL = NSURL(string: requestUrlString){
            var session = NSURLSession.sharedSession()
            var task:NSURLSessionTask = session.dataTaskWithURL(url, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
                if(error != nil){
                    completion(autosuggests: [], error: error)
                }else{
                    var jsonError:NSError?
                    var json:NSDictionary? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary
                    if (json == nil || jsonError != nil) {
                        completion(autosuggests: [], error: error)
                    }
                    else {
                        var autoSuggestions:[String] = []
                        if let predictions = json!["predictions"] as? NSArray{
                            for prediction in predictions{
                                if let predictionDict = prediction as? NSDictionary{
                                    if let terms = predictionDict["terms"] as? NSArray{
                                        if (terms.count > 0){
                                            if let termDict = terms[0] as? NSDictionary{
                                                if let value = termDict["value"] as? String{
                                                    autoSuggestions.append(value)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        println(autoSuggestions)
                        completion(autosuggests: autoSuggestions, error: nil)
                    }
                }
            })
            task.resume()
        }
    }
    
}
