//
//  CurrentGeocode.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/26.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation
import CoreLocation

class CurrentGeocode: NSObject, CLLocationManagerDelegate {
    var geocoder:CLGeocoder = CLGeocoder()
    var myLocationManager:CLLocationManager = CLLocationManager()
    typealias GeocodeCompletionHandler = (CLPlacemark?) -> Void
    var completionHandler:GeocodeCompletionHandler

    init(completionHandler: GeocodeCompletionHandler) {
        self.completionHandler = completionHandler
        super.init()
        myLocationManager.delegate = self
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.startUpdatingLocation()
    }

    func internalGeocodeCompletionHandler(placemarks: [CLPlacemark]?, error: NSError?) {
        if (placemarks != nil && placemarks!.count > 0) {
            let placemark = placemarks!.first
            completionHandler(placemark)
        } else {
            completionHandler(nil)
        }
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocationManager.stopUpdatingLocation()
        if (locations.count == 0) {
            completionHandler(nil)
        } else {
            if let locationObject:CLLocation = locations.first! as CLLocation {
                geocoder.reverseGeocodeLocation(locationObject, completionHandler: internalGeocodeCompletionHandler)
            }
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        myLocationManager.stopUpdatingLocation()
        completionHandler(nil)
    }
}