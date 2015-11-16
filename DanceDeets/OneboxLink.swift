//
//  OneboxLink.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/11/16.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation

public class OneboxLink: NSObject {

    var title: String?
    var url: String?

    init(dictionary:NSDictionary) {
        super.init()
        title = dictionary["title"] as? String
        url = dictionary["url"] as? String
    }
}