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

    var request: DFPRequest
    var setLocation: Bool = false

    var interstitial: DFPInterstitial

    let kInterstitialAdUnitId = "/26589588/mobile-interstitial"
    let kBottomBannerAdUnitId = "/26589588/mobile-bottom-banner"

    init(controller: EventStreamViewController) {
        self.controller = controller
        self.request = DFPRequest()
        self.request.testDevices = [
            kGADSimulatorID,
            "301ebb9f19659a3ebbc88d348b8810b5", // Mike's iPhone
        ]
        self.interstitial = DFPInterstitial(adUnitID: kInterstitialAdUnitId)
        super.init()
        fetchLocation = FetchLocation(completionHandler: locationFoundHandler)
    }

    func locationFoundHandler(optionalLocation: CLLocation?) {
        controller.bannerView.adUnitID = kBottomBannerAdUnitId
        controller.bannerView.rootViewController = controller
        controller.bannerView.adSize = kGADAdSizeSmartBannerPortrait

        if let location = optionalLocation {
            setLocation = true
            request.setLocationWithLatitude(
                CGFloat(location.coordinate.latitude),
                longitude: CGFloat(location.coordinate.longitude),
                accuracy: CGFloat(max(location.horizontalAccuracy, location.verticalAccuracy))
            )
        }
        loadIfTokenComplete()
    }

    func setupAccessToken() {
        // Needs to be 30 characters or more, and needs to be meaningless to Google.
        // But needs to be unique to the user, for frequency capping purposes.
        if let userID = FBSDKAccessToken.currentAccessToken()?.userID {
            request.publisherProvidedID = userID.MD5()
        }
        loadIfTokenComplete()
    }

    func loadIfTokenComplete() {
        if request.publisherProvidedID != nil && setLocation {
            controller.bannerView.delegate = self
            controller.bannerView.loadRequest(request)
            interstitial.loadRequest(request)
        }
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

    func maybeShowInterstitialAd() {
        if interstitial.isReady {
            interstitial.presentFromRootViewController(controller)
        }
    }
}