//
//  EventDetailDescriptionCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//
import UIKit

class EventDetailDescriptionCell: UITableViewCell {
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        eventDescriptionLabel.numberOfLines = 0
        eventDescriptionLabel.backgroundColor = UIColor.clearColor()
    }
    
    func updateViewForEvent(event:Event){
        
        var attributedDescription = NSMutableAttributedString(string: event.shortDescription!)
        attributedDescription.setLineHeight(FontFactory.eventDescriptionLineHeight())
        attributedDescription.setFont(FontFactory.eventDescriptionFont())
        attributedDescription.setColor(UIColor.whiteColor())
        
        eventDescriptionLabel.attributedText = attributedDescription
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
