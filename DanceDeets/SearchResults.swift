//
//  SearchResults.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/11/16.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation

public class SearchResults: NSObject {

    public var events:[Event]
    public var oneboxLinks:[OneboxLink]

    init(json: NSDictionary) {
        events = []
        oneboxLinks = []
        super.init()
        if let results = json["results"] as? NSArray {
            for item in results {
                if let eventDictionary = item as? NSDictionary {
                    let newEvent = Event(dictionary: eventDictionary)
                    events.append(newEvent)
                }
            }
        }
        if let results = json["onebox_links"] as? NSArray {
            for item in results {
                if let oneboxDictionary = item as? NSDictionary {
                    let oneboxLink = OneboxLink(dictionary: oneboxDictionary)
                    oneboxLinks.append(oneboxLink)
                }
            }
        }
    }
}