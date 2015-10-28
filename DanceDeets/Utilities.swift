//
//  Utilities.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

class Utilities{
    
    class func heightRequiredForText(text:String, lineHeight:CGFloat, font:UIFont, width:CGFloat)->CGFloat{
        let nsStr = NSString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        let attributesDictionary:[String:AnyObject] =
        [NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName:font]
        
        let bounds =
        nsStr.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributesDictionary, context: nil)
        return bounds.size.height;
    }
    
    class func printFontFamilies()
    {
        for name in UIFont.familyNames()
        {
                let names = UIFont.fontNamesForFamilyName(name)
                print(name)
                print(names)
        }
    }

    class func dateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        // Because otherwise the user's AM/PM vs 24-hour times will *override* our dateFormat above
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter
    }

}