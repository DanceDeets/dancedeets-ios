//
//  UserSettings.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation


class UserSettings
{
    class func getUserCities()->[String]{
        let userCities = NSUserDefaults.standardUserDefaults().arrayForKey("userCities")
        if(userCities == nil){
            // default cities
            let defaultCities = ["New York City","Los Angeles", "San Francisco"]
            NSUserDefaults.standardUserDefaults().setObject(defaultCities, forKey: "userCities")
            NSUserDefaults.standardUserDefaults().synchronize()
            return defaultCities
        }else{
            return userCities as [String]
        }
    }
    
    class func addUserCity(city:String){
        var userCities = NSUserDefaults.standardUserDefaults().arrayForKey("userCities")
        if(userCities != nil){
            userCities!.append(city)
            NSUserDefaults.standardUserDefaults().setObject(userCities, forKey: "userCities")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class func getUserCitySearch()->String{
        let city = NSUserDefaults.standardUserDefaults().stringForKey("searchCity")
        if(city == nil){
            // default cities
            NSUserDefaults.standardUserDefaults().setObject("", forKey: "searchCity")
            NSUserDefaults.standardUserDefaults().synchronize()
            return ""
        }else{
            return city!
        }
    }
    
    class func setUserCitySearch(city:String){
        NSUserDefaults.standardUserDefaults().setObject(city, forKey: "searchCity")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}