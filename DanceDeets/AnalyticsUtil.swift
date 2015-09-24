//
//  AnalyticsUtil.swift
//  DanceDeets
//
//  Created by Mike Lambert on 2015/09/24.
//  Copyright © 2015 Mike Lambert. All rights reserved.
//

import Foundation
import Mixpanel

public class AnalyticsUtil {
    static let MIXPANEL_TOKEN = "f5d9d18ed1bbe3b190f9c7c7388df243"

    public class func createInstance() {
        Mixpanel.sharedInstanceWithToken(MIXPANEL_TOKEN)
    }
    
/*    public func login(user: User) {
        Mixpanel.sharedInstance().identify(user.getId)
        //        parameters.putString("fields", "id,name,first_name,last_name,gender,locale,timezone,email,link");
    }
*/
    
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