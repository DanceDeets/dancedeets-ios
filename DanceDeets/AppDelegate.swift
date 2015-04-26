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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var fbGraphUserObjectId:String?
    let urlCacheMemoryCapacityMB = 48
    let urlCacheDiskCapacityMB = 128
    var allowLandscape:Bool?
    
    class func sharedInstance() -> AppDelegate
    {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func eventStreamViewController()->EventStreamViewController?
    {
        let rootVC:UINavigationController? =  window?.rootViewController as? UINavigationController
        if(rootVC?.viewControllers.count > 0){
            return rootVC?.viewControllers[0] as? EventStreamViewController
        }else{
            return nil
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FBLoginView.self
        FBProfilePictureView.self
        
        // ios url cache defaults to 512KB/10MB. The cover photos can get pretty big so up the defaults
        let sharedURLCache = NSURLCache(memoryCapacity: urlCacheMemoryCapacityMB*1024*1024,
            diskCapacity: urlCacheDiskCapacityMB*1024*1024, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedURLCache)
        Fabric.with([Crashlytics()])
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
    {
        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication! as String)
        return wasHandled
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> Int {
        var returnValue:Int = Int(UIInterfaceOrientationMask.Portrait.rawValue)
        if let allowLandscape = allowLandscape {
            if(allowLandscape){
                returnValue = Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
            }
        }
        
        return returnValue
    }
    
    
}

