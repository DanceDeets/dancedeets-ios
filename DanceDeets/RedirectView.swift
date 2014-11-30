//
//  RedirectView.swift
//  DanceDeets
//
//  Created by David Xiang on 11/29/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class RedirectView: UIView {
    
    var redirectedView:UIView?
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        let hitView = super.hitTest(point, withEvent:event)
        if(hitView == self){
            return redirectedView
        }
        return hitView
    }
    
}
