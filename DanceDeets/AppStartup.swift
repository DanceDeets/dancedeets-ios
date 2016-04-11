//
//  AppStartup.swift
//  DanceDeets
//
//  Created by LambertMike on 2016/03/27.
//  Copyright © 2016年 david.xiang. All rights reserved.
//

import Foundation

class AppStartup {

    class func getTargetUrl(url: NSURL) -> NSURL? {
        if let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
            if let items = urlComponents.queryItems {
                for item in items {
                    if item.name == "target_url" {
                        let targetUrl = item.value
                        return NSURL(string: targetUrl!)
                    }
                }
            }
        }
        return nil
    }

   class func getEventIdFromUrl(url: NSURL) -> String? {
        if let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
            if let pathComponents = urlComponents.path?.componentsSeparatedByString("/") {
                if pathComponents.count > 2 && pathComponents[1] == "events" {
                    return pathComponents[2]
                }
            }
        }
        return nil
    }

}
