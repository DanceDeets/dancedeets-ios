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
    
    // TODO clean up when class variables supported
    class func descriptionFont()->UIFont{
        return UIFont(name: "Montserrat-Regular", size: 16.0)!
    }
    class func descriptionLineHeight()->CGFloat{
        return 20.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        eventDescriptionLabel.numberOfLines = 0
        eventDescriptionLabel.backgroundColor = UIColor.clearColor()
    }
    
    func updateViewForEvent(event:Event){
        
        var attributedDescription = NSMutableAttributedString(string: event.shortDescription!)
        attributedDescription.setLineHeight(EventDetailDescriptionCell.descriptionLineHeight())
        attributedDescription.setFont(EventDetailDescriptionCell.descriptionFont())
        attributedDescription.setColor(UIColor.whiteColor())
        
        eventDescriptionLabel.attributedText = attributedDescription
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
