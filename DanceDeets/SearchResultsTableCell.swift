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
    var tagLabel:UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clearColor()
        
        selectionStyle = UITableViewCellSelectionStyle.None
        
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel?.textColor = UIColor.whiteColor()
        titleLabel?.font = UIFont(name: "BebasNeueBold", size: 26)
        titleLabel?.numberOfLines = 0
        titleLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(titleLabel!)
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 15.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -15.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10.0))
        
        tagLabel = UILabel(frame: CGRectZero)
        tagLabel?.textColor = ColorFactory.lightBlue()
        tagLabel?.font =  UIFont(name:"Montserrat-Bold", size:14)
        tagLabel?.numberOfLines = 0
        tagLabel?.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(tagLabel!)
        contentView.addConstraint(NSLayoutConstraint(item: tagLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 5.0))
        contentView.addConstraint(NSLayoutConstraint(item: tagLabel!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: tagLabel!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: tagLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -10.0))
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateForEvent(event:Event)
    {
        titleLabel?.text = event.title
        titleLabel?.sizeToFit()
        
        tagLabel?.text = event.tagString
        tagLabel?.sizeToFit()
        
        contentView.layoutIfNeeded()
    }
    
}
