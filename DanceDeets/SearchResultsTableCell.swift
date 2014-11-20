//
//  SearchResultsTableCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class SearchResultsTableCell: UITableViewCell {
    
    var titleLabel:UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        
        // 1
        let blurEffect = UIBlurEffect(style: .Dark)
        // 2
        let blurView = UIVisualEffectView(effect: blurEffect)
        // 3
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.insertSubview(blurView,atIndex:0)
        blurView.constrainToSuperViewEdges()
        
        
        // 1
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        // 2
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.setTranslatesAutoresizingMaskIntoConstraints(false)
        // 3
        titleLabel = UILabel(frame: CGRectZero)
        
        let innerContentView = UIView(frame: CGRectZero)
        innerContentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // 4
        //vibrancyView.constrainToSuperViewEdges()
        
        
        vibrancyView.contentView.addSubview(titleLabel!)
        titleLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel!.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0))
        vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel!.superview, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 20.0))
        
        blurView.contentView.addSubview(vibrancyView)
       // vibrancyView.frame = CGRectMake(0, 0, 60, 40)
        vibrancyView.constrainToSuperViewEdges()
        
       
    }
    
    required init(coder : NSCoder) {
        super.init(coder: coder)
    }
    
    func updateForEvent(event:Event)
    {
        //titleLabel?.textColor = UIColor.greenColor()
        titleLabel?.text = event.title
        titleLabel?.sizeToFit()
    }
    
}
