//
//  Extensions.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

extension NSMutableAttributedString{
    
    func setLineHeight(height:CGFloat){
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight =  height
        paragraphStyle.maximumLineHeight =  height
        
        self.addAttribute(NSParagraphStyleAttributeName,
            value: paragraphStyle,
            range: NSMakeRange(0, countElements(self.string)))
    }
    
    func setFont(font:UIFont){
        self.addAttribute(NSFontAttributeName,
            value: font,
            range: NSMakeRange(0, countElements(self.string)))
    }
    
    func setColor(color:UIColor){
        self.addAttribute(NSForegroundColorAttributeName,
            value: color,
            range: NSMakeRange(0, countElements(self.string)))
    }
}
