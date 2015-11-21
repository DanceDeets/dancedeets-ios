//
//  AppDelegate.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FBSDKCoreKit
import FBSDKLoginKit
import Mixpanel
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var fbGraphUserObjectId:String?
    let urlCacheMemoryCapacityMB = 48
    let urlCacheDiskCapacityMB = 128
    var allowLandscape:Bool?
    var originalTintColor: UIColor?

    class func sharedInstance() -> AppDelegate
    {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func eventStreamViewController()->EventStreamViewController?
    {
        let rootVC:UINavigationController? =  window?.rootViewController as? UINavigationController
        if (rootVC?.viewControllers.count > 0) {
            return rootVC?.viewControllers[0] as? EventStreamViewController
        } else {
            return nil
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Only do the badging on debug builds, as this API will get you rejected from the App Store apps.
        #if DEBUG
            // TODO: someday move this to the main app flow with proper priming before asking
            let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().performSelector("setApplicationBadgeString:", withObject:"β");
        #endif


        FBSDKLoginButton.self
        FBSDKProfilePictureView.self
        DFPRequest.sdkVersion()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        // ios url cache defaults to 512KB/10MB. The cover photos can get pretty big so up the defaults
        let sharedURLCache = NSURLCache(memoryCapacity: urlCacheMemoryCapacityMB*1024*1024,
            diskCapacity: urlCacheDiskCapacityMB*1024*1024, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedURLCache)

        Fabric.with([Crashlytics()])
        
        AnalyticsUtil.createInstance()

        originalTintColor = window?.tintColor
        window?.tintColor = UIColor.whiteColor()

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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

