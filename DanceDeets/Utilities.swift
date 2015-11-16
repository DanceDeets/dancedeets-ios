//
//  Utilities.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

class Utilities {

    class func dateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        // Because otherwise the user's AM/PM vs 24-hour times will *override* our dateFormat above
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter
    }

}