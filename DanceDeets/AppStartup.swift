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

   class  func getEventIdFromUrl(url: NSURL) -> String? {
        if let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) {
            if let pathComponents = urlComponents.path?.componentsSeparatedByString("/") {
                print(pathComponents)
                if pathComponents.count > 2 && pathComponents[1] == "events" {
                    if pathComponents[2].containsOnlyCharactersIn("0123456789") {
                        return pathComponents[2]
                    }
                }
            }
        }
        return nil
    }


    class func loadEventData(eventId: String) {
        print(eventId)
        // Trigger load, with callback
        // loadedEventData
    }


    func loadedEventData(event: Event) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let destination = storyboard.instantiateViewControllerWithIdentifier("eventInfoViewController") as! EventInfoViewController
        destination.events = []
        destination.startEvent = event
    }
}
