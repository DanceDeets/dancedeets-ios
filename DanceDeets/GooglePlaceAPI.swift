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
       // return "AIzaSyD8E6t-CTw6yTEynHcCqY6kzA0z2LdyEGU"
       // return "AIzaSyBQN4RgOgFVnFidWJZgOJX4AOat9L3oIjw"
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
                                    if let description = predictionDict["description"] as? String{
                                        if (countElements(description) > 0){
                                            autoSuggestions.append(description)
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
    
}
