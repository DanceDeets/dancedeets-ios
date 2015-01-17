//
//  UserSettings.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

/*
 * Persisting basic user city search settings
 */
class UserSettings
{
    class var DEFAULT_CITIES : [String] {
        return ["New York, NY","Los Angeles, CA", "San Francisco, CA", "Paris, France"]
    }
    class var USER_CITIES_KEY : String{
        return "userCities"
    }
    class var USER_SEARCH_CITY_KEY : String{
        return "searchCity"
    }
    
    class func getUserCities()->[String]{
        let userCities = NSUserDefaults.standardUserDefaults().arrayForKey(UserSettings.USER_CITIES_KEY)
        if(userCities == nil){
            NSUserDefaults.standardUserDefaults().setObject(UserSettings.DEFAULT_CITIES, forKey: UserSettings.USER_CITIES_KEY)
            NSUserDefaults.standardUserDefaults().synchronize()
            return UserSettings.DEFAULT_CITIES
        }else{
            return userCities as [String]
        }
    }
    
    class func addUserCity(city:String){
        var userCities = NSUserDefaults.standardUserDefaults().arrayForKey(UserSettings.USER_CITIES_KEY) as? [String]
        if(userCities != nil ){
            let index = find(userCities!,city)
            if(index == nil){
                userCities!.append(city)
                NSUserDefaults.standardUserDefaults().setObject(userCities, forKey: UserSettings.USER_CITIES_KEY)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    class func deleteUserCity(city:String){
        var userCities = NSUserDefaults.standardUserDefaults().arrayForKey(UserSettings.USER_CITIES_KEY) as [String]
        if let index = find(userCities,city){
            userCities.removeAtIndex(index)
            NSUserDefaults.standardUserDefaults().setObject(userCities, forKey: UserSettings.USER_CITIES_KEY)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class func getUserCitySearch()->String{
        let city = NSUserDefaults.standardUserDefaults().stringForKey(UserSettings.USER_SEARCH_CITY_KEY)
        if(city == nil){
            NSUserDefaults.standardUserDefaults().setObject("", forKey: UserSettings.USER_SEARCH_CITY_KEY)
            NSUserDefaults.standardUserDefaults().synchronize()
            return ""
        }else{
            return city!
        }
    }
    
    class func setUserCitySearch(city:String){
        NSUserDefaults.standardUserDefaults().setObject(city, forKey: UserSettings.USER_SEARCH_CITY_KEY)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}