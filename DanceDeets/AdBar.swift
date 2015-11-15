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

    var controller: UIViewController
    var eventStreamController: EventStreamViewController?
    var fetchLocation: FetchLocation?

    var request: DFPRequest
    var setLocation: Bool = false

    var interstitial: DFPInterstitial

    let kInterstitialAdUnitId = "/26589588/mobile-interstitial"
    let kBottomBannerAdUnitId = "/26589588/mobile-bottom-banner"

    init(controller: UIViewController) {
        self.controller = controller
        self.eventStreamController = controller as? EventStreamViewController
        self.request = DFPRequest()
        self.request.testDevices = [
            kGADSimulatorID,
            "301ebb9f19659a3ebbc88d348b8810b5", // Mike's iPhone
        ]
        self.interstitial = DFPInterstitial(adUnitID: kInterstitialAdUnitId)

        super.init()

        self.fetchLocation = FetchLocation(completionHandler: locationFoundHandler)
        setupAccessToken()
    }

    func locationFoundHandler(optionalLocation: CLLocation?) {
        eventStreamController?.bannerView.adUnitID = kBottomBannerAdUnitId
        eventStreamController?.bannerView.rootViewController = controller
        eventStreamController?.bannerView.adSize = kGADAdSizeSmartBannerPortrait

        setLocation = true
        if let location = optionalLocation {
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
            eventStreamController?.bannerView.delegate = self
            eventStreamController?.bannerView.loadRequest(request)
            interstitial.loadRequest(request)
        }
    }

    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        eventStreamController?.bannerViewHeight.constant = 50
        controller.view.layoutIfNeeded()
    }

    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("No Ad ", error)
        eventStreamController?.bannerViewHeight.constant = 0
        controller.view.layoutIfNeeded()
    }

    func maybeShowInterstitialAd() {
        if interstitial.isReady {
            interstitial.presentFromRootViewController(controller)
        }
    }
}