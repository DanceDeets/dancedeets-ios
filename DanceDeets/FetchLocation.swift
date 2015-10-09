//
//  FetchLocation.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/26.
//

import Foundation
import CoreLocation

class FetchLocation: NSObject, CLLocationManagerDelegate {
    var myLocationManager:CLLocationManager = CLLocationManager()
    typealias LocationCompletionHandler = (CLLocation?) -> Void
    var completionHandler:LocationCompletionHandler

    init(completionHandler: LocationCompletionHandler) {
        self.completionHandler = completionHandler
        super.init()
        myLocationManager.delegate = self
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.startUpdatingLocation()
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocationManager.stopUpdatingLocation()
        if (locations.count == 0) {
            completionHandler(nil)
        } else {
            completionHandler(locations.first!)
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        myLocationManager.stopUpdatingLocation()
        completionHandler(nil)
    }
}