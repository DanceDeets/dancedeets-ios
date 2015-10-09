//
//  FetchAddress.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/26.
//

import Foundation
import CoreLocation

class FetchAddress: NSObject, CLLocationManagerDelegate {
    var geocoder:CLGeocoder = CLGeocoder()
    var myLocationManager:CLLocationManager = CLLocationManager()
    typealias AddressCompletionHandler = (CLPlacemark?) -> Void
    var completionHandler:AddressCompletionHandler

    init(completionHandler: AddressCompletionHandler) {
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
            if let locationObject = locations.first {
                geocoder.reverseGeocodeLocation(locationObject, completionHandler: internalGeocodeCompletionHandler)
            }
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        myLocationManager.stopUpdatingLocation()
        completionHandler(nil)
    }
}