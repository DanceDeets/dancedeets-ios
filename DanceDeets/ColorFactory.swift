//
//  ColorFactory.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation


class ColorFactory {
    
    class func darkYellow()->UIColor{
        return UIColor(red: 255.0/255.0, green: 208.0/255.0, blue: 141.0/255.0, alpha: 1.0)
    }
    
    class func lightBlue()->UIColor{
        return UIColor(red: 0.0/255.0, green: 236.0/255.0, blue: 227.0/255.0, alpha: 1.0)
    }
    
    class func tableSeparatorColor()->UIColor{
        return UIColor.whiteColor().colorWithAlphaComponent(0.3)
    }
    
}