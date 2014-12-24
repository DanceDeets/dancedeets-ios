//
//  FontFactory.swift
//  DanceDeets
//
//  Created by David Xiang on 10/4/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import UIKit

class FontFactory {
    
    class func navigationTitleFont()->UIFont{
        return UIFont(name:"UniversLTStd-UltraCn",size: 22)!
    }
    class func eventHeadlineFont()->UIFont{
        return UIFont(name:"Interstate-ExtraLight",size:22)!
    }
    class func eventHeadlineLineHeight()->CGFloat{
        return 24.0
    }
    class func eventDateFont()->UIFont{
        return UIFont(name:"Interstate-BoldCondensed",size:15)!
    }
    class func eventDescriptionFont()->UIFont{
        return UIFont(name:"Interstate-Light",size:13)!
    }
    class func eventDescriptionLineHeight()->CGFloat{
        return 18.0
    }
    class func eventVenueFont()->UIFont{
        return UIFont(name:"Interstate-Light",size:13)!
    }
    class func eventVenueLineHeight()->CGFloat{
        return 18.0
    }
    class func barButtonFont()->UIFont{
        return UIFont(name:"Interstate-Light",size:13)!
    }
    class func standardTableLabelFont()->UIFont{
        return UIFont(name:"Interstate-Light",size:15)!
    }
    class func textFieldFont()->UIFont{
        return UIFont(name:"Interstate-Light",size:18)!
    }
    class func settingsHeaderFont()->UIFont{
        return UIFont(name:"Interstate-BoldCondensed",size:15)!
    }
}