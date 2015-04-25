//
//  SearchResultsTableCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class SearchAutoSuggestTableCell: UITableViewCell {
    
    var titleLabel:UILabel!
    var magGlass:UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        magGlass = UIImageView(image: UIImage(named: "searchIconSmall")!)
        magGlass.tintColor = UIColor.whiteColor()
        magGlass.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(magGlass)
        contentView.addConstraint(NSLayoutConstraint(item: magGlass, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: magGlass, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1.0, constant: 15.0))
        
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = FontFactory.eventHeadlineFont()
        titleLabel.numberOfLines = 0
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(titleLabel!)
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: .Left, multiplier: 1.0, constant: 35.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -15.0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10.0))
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
