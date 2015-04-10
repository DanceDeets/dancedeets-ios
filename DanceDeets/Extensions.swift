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
            range: NSMakeRange(0, count(self.string)))
    }
    
    func setFont(font:UIFont){
        self.addAttribute(NSFontAttributeName,
            value: font,
            range: NSMakeRange(0, count(self.string)))
    }
    
    func setColor(color:UIColor){
        self.addAttribute(NSForegroundColorAttributeName,
            value: color,
            range: NSMakeRange(0, count(self.string)))
    }
    
    func setBackgroundColor(color:UIColor){
        self.addAttribute(NSBackgroundColorAttributeName,
            value: color,
            range: NSMakeRange(0, count(self.string)))
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