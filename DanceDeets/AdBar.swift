//
//  AdBar.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/10/09.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMobileAds

class AdBar : NSObject, GADBannerViewDelegate {

    var controller: EventStreamViewController
    var fetchLocation: FetchLocation?

    init(controller: EventStreamViewController) {
        self.controller = controller
        super.init()
        fetchLocation = FetchLocation(completionHandler: locationFoundHandler)
    }

    func locationFoundHandler(optionalLocation: CLLocation?) {
        controller.bannerView.adUnitID = "/26589588/mobile-bottom-banner"
        controller.bannerView.rootViewController = controller
        controller.bannerView.adSize = kGADAdSizeSmartBannerPortrait
        let request = DFPRequest()
        request.testDevices = [
            kGADSimulatorID,
            "301ebb9f19659a3ebbc88d348b8810b5", // Mike's iPhone
        ]
        if let location = optionalLocation {
            request.setLocationWithLatitude(
                CGFloat(location.coordinate.latitude),
                longitude: CGFloat(location.coordinate.longitude),
                accuracy: CGFloat(max(location.horizontalAccuracy, location.verticalAccuracy))
            )
        }

        // Needs to be 30 characters or more, and needs to be meaningless to Google.
        // But needs to be unique to the user, for frequency capping purposes.
        request.publisherProvidedID = FBSDKAccessToken.currentAccessToken().userID.MD5()
        controller.bannerView.delegate = self
        controller.bannerView.loadRequest(request)
    }

    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        controller.bannerViewHeight.constant = 50
        controller.view.layoutIfNeeded()
    }

    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("No Ad ", error)
        controller.bannerViewHeight.constant = 0
        controller.view.layoutIfNeeded()
    }
}