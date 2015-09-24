//
//  Venue.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/24.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation

public class Venue {
    var id:String?
    var name:String?
    
    var latLong:(Double, Double)?
    
    var street:String?
    var city:String?
    var state:String?
    var zip:String?
    var country:String?
    
    
    init(_ venue: NSDictionary) {

        if let geocodeDict = venue["geocode"] as? NSDictionary{
            latLong = (geocodeDict["latitude"] as! Double, geocodeDict["longitude"] as! Double)
        }
        id = venue["id"] as? String
        name = venue["name"] as? String
        if let address = venue["address"] {
            street = address["street"] as? String
            city = address["city"] as? String
            state = address["state"] as? String
            zip = address["zip"] as? String
            country = address["country"] as? String
        }
    }
    
    public func cityStateZip() -> String {
        let components = [city, state, country]
        return components.filter({$0 != nil}).map({$0!}).joinWithSeparator(", ")
    }
}
