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
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        
        
        var attributesDictionary:[NSObject:AnyObject] =
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
            if let nameString = name as? String{
                let names = UIFont.fontNamesForFamilyName(nameString)
                println(nameString)
                println(names)
            }
        }
    }
}