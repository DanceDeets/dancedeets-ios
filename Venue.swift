//
//  Venue.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/24.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import AddressBookUI
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

    var cityStateAddressDictionary:[String:String]
    var fullAddressDictionary:[String:String]

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
            country = address["country"] as? String
        }

        var addressDictionary = [String:String]()
        if city != nil {
            addressDictionary[kABPersonAddressCityKey as String] = city
        }
        if state != nil {
            addressDictionary[kABPersonAddressStateKey as String] = state
        }
        addressDictionary[kABPersonAddressCountryCodeKey as String] = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String

        cityStateAddressDictionary = addressDictionary
        fullAddressDictionary = addressDictionary

        if country != nil {
            fullAddressDictionary[kABPersonAddressCountryKey as String] = country
        }
        if street != nil {
            fullAddressDictionary[kABPersonAddressStreetKey as String] = street
        }
    }

    private func prefixName(postfix: String) -> String {
        if let realName = name {
            return "\(realName)\n\(postfix)"
        } else {
            return postfix
        }
    }

    public func formattedNameAndCity() -> String {
        let city = formattedCity()
        return prefixName(city)
    }


    public func formattedCity() -> String {
        let city = ABCreateStringWithAddressDictionary(cityStateAddressDictionary, false)
        return city
    }

    public func formattedFull() -> String {
        let address = ABCreateStringWithAddressDictionary(fullAddressDictionary, true)
        return prefixName(address)
    }
}
