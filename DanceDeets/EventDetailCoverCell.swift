//
//  EventDetailCoverCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/8/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventDetailCoverCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        titleLabel.font = FontFactory.eventHeadlineFont()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.numberOfLines = 0
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    func updateViewForEvent(event:Event){
        
        if let title = event.title{
            var attributedTitle = NSMutableAttributedString(string: title)
            attributedTitle.setFont(FontFactory.eventHeadlineFont())
            attributedTitle.setColor(UIColor.whiteColor())
            attributedTitle.setLineHeight(FontFactory.eventHeadlineLineHeight())
            titleLabel.attributedText = attributedTitle
        }
        
        contentView.layoutIfNeeded()
    }
}
