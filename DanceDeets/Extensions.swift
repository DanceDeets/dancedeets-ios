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


extension UIView{
    /* view must have been added to super view before calling this*/
    func constrainToSuperViewEdges(){
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0))
        self.superview?.addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.superview, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0))
        self.superview?.layoutIfNeeded()
    }
    
    func fadeOut(time:NSTimeInterval){
        UIView.animateWithDuration(time, animations: { () -> Void in
            self.alpha = 0.0
        })
    }

    func fadeIn(time:NSTimeInterval){
        UIView.animateWithDuration(time, animations: { () -> Void in
            self.alpha = 1.0
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