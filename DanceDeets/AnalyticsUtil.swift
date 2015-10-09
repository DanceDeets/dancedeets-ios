//
//  AnalyticsUtil.swift
//  DanceDeets
//
//  Created by Mike Lambert on 2015/09/24.
//  Copyright © 2015 Mike Lambert. All rights reserved.
//

import Crashlytics
import Foundation
import Mixpanel

public class AnalyticsUtil {

    #if DEBUG
    static let MIXPANEL_TOKEN = "668941ad91e251d2ae9408b1ea80f67b"
    #else
    static let MIXPANEL_TOKEN = "f5d9d18ed1bbe3b190f9c7c7388df243"
    #endif

    public class func createInstance() {
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
        track("$app_open")
    }

    public class func login() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,first_name,last_name,gender,locale,timezone,email,link"])
            request.startWithCompletionHandler(userInfoComplete)
        }
    }

    private class func userInfoComplete(connection: FBSDKGraphRequestConnection!, user: AnyObject!, error: NSError!) {
        if (error != nil) {
            print("Error fetching \(connection), received \(error)")
        } else {
            // Not MixPanel analytics, but Crashlytics "analytics" of a sort.
            Crashlytics.sharedInstance().setUserEmail(user["email"] as? String)
            Crashlytics.sharedInstance().setUserIdentifier(user["id"] as? String)
            Crashlytics.sharedInstance().setUserName(user["name"] as? String)

            // Our normal MixPanel analytics setup
            Mixpanel.sharedInstance().identify(user["id"] as! String)

            if let val = user["first_name"] as? String {
                Mixpanel.sharedInstance().people.set("$first_name", to: val)
            }
            if let val = user["last_name"] as? String {
                Mixpanel.sharedInstance().people.set("$last_name", to: val)
            }
            if let val = user["gender"] as? String {
                Mixpanel.sharedInstance().people.set("FB Gender", to: val)
            }
            if let val = user["locale"] as? String {
                Mixpanel.sharedInstance().people.set("FB Locale", to: val)
            }
            if let val = user["timezone"] as? String {
                Mixpanel.sharedInstance().people.set("FB Timezone", to: val)
            }
            if let val = user["email"] as? String {
                Mixpanel.sharedInstance().people.set("$email", to: val)
            }

            let dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
            let today = dateFormatter.stringFromDate(NSDate())
            Mixpanel.sharedInstance().people.set("Last Login", to: today);
            Mixpanel.sharedInstance().people.setOnce(["$created": today]);
        }
    }

    public class func logout() {
        Mixpanel.sharedInstance().reset()
    }
    
    public class func setGlobalProperties(keyValuePairs: [String: String]) {
        Mixpanel.sharedInstance().registerSuperProperties(keyValuePairs)
    }

    public class func track(eventName: String, _ args: [String: String]? = nil) {
        Mixpanel.sharedInstance().track(eventName, properties: args)
    }

    public class func track(eventName: String, withEvent event: Event, _ args: [String: String] = [:]) {
        var props = args
        props["Event ID"] = event.id!
        props["Event City"] = event.venue?.cityStateZip()
        props["Event Country"] = event.venue?.country
        Mixpanel.sharedInstance().track(eventName, properties: props)
    }

}