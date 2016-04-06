//
//  AppDelegate.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Crashlytics
import Fabric
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMobileAds
import Mixpanel
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var fbGraphUserObjectId: String?
    let urlCacheMemoryCapacityMB = 48
    let urlCacheDiskCapacityMB = 128
    var allowLandscape: Bool?
    var deviceToken: NSData?

    class func sharedInstance() -> AppDelegate
    {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Only do the badging on debug builds, as this API will get you rejected from the App Store apps.
        #if DEBUG
            // TODO: someday move this to the main app flow with proper priming before asking
            let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().performSelector(Selector("setApplicationBadgeString:"), withObject:"β");
        #endif

        CLSNSLogv("Google Mobile Ads SDK version: %@", getVaList([DFPRequest.sdkVersion()]))

        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // ios url cache defaults to 512KB/10MB. The cover photos can get pretty big so up the defaults
        let sharedURLCache = NSURLCache(memoryCapacity: urlCacheMemoryCapacityMB*1024*1024,
            diskCapacity: urlCacheDiskCapacityMB*1024*1024, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedURLCache)

        Fabric.with([Crashlytics()])
        
        AnalyticsUtil.createInstance()

        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Mixpanel.sharedInstance().people.addPushDeviceToken(deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Error", error)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        if let targetUrl = AppStartup.getTargetUrl(url) {
            print(targetUrl)
            if let eventId = AppStartup.getEventIdFromUrl(targetUrl) {
                AppStartup.loadEventData(eventId)
            }
        }
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Notification received:", userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
      
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        var returnValue:UIInterfaceOrientationMask = UIInterfaceOrientationMask.Portrait
        if let allowLandscape = allowLandscape {
            if allowLandscape {
                returnValue = UIInterfaceOrientationMask.AllButUpsideDown
            }
        }
        return returnValue
    }
}

