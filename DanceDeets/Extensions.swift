//
//  Extensions.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

extension Int {
    func hexString() -> String {
        return String(format:"%02x", self)
    }
}

extension NSData {
    func hexString() -> String {
        var string = String()
        for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: length) {
            string += Int(i).hexString()
        }
        return string
    }

    func MD5() -> NSData {
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }

    func SHA1() -> NSData {
        let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
        CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
        return NSData(data: result)
    }
}

extension String {
    func MD5() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.MD5().hexString()
    }

    func SHA1() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.SHA1().hexString()
    }
}

extension NSMutableAttributedString{
    
    func setLineHeight(height:CGFloat){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight =  height
        paragraphStyle.maximumLineHeight =  height
        
        self.addAttribute(NSParagraphStyleAttributeName,
            value: paragraphStyle,
            range: NSMakeRange(0, self.string.characters.count))
    }
    
    func setFont(font:UIFont){
        self.addAttribute(NSFontAttributeName,
            value: font,
            range: NSMakeRange(0, self.string.characters.count))
    }
    
    func setColor(color:UIColor){
        self.addAttribute(NSForegroundColorAttributeName,
            value: color,
            range: NSMakeRange(0, self.string.characters.count))
    }
    
    func setBackgroundColor(color:UIColor){
        self.addAttribute(NSBackgroundColorAttributeName,
            value: color,
            range: NSMakeRange(0, self.string.characters.count))
    }
}

extension UIView{

    func fadeOut(time:NSTimeInterval,completion:(()->Void)?){
        UIView.animateWithDuration(time, animations: { () -> Void in
            self.alpha = 0.0
            },completion:{(bool:Bool) -> Void in
                if(completion != nil){
                    completion!()
                }
        })
    }

    func fadeIn(time:NSTimeInterval,completion:(()->Void)?){
        UIView.animateWithDuration(time, animations: { () -> Void in
            self.alpha = 1.0
            },completion:{(bool:Bool) -> Void in
                if(completion != nil){
                    completion!()
                }
        })
    }
    
    // adds a dark blur overlay to the view and returns reference to it.
    func addDarkBlurOverlay()->UIView{
        let overlay = UIView(frame: CGRectZero)
        addSubview(overlay)
        overlay.constrainToSuperViewEdges()
        
        let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style:UIBlurEffectStyle.Dark)) as UIVisualEffectView
        overlay.addSubview(visualEffect)
        visualEffect.constrainToSuperViewEdges()
        
        return overlay
    }
}