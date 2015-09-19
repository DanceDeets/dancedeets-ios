//
//  EventDetailDescriptionCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//
import UIKit

class EventDetailDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        textView.backgroundColor = UIColor.clearColor()
        textView.scrollEnabled = false
        textView.textContainerInset = UIEdgeInsetsZero
        textView.font = FontFactory.eventDescriptionFont()
        textView.tintColor = ColorFactory.lightBlue()
    }
    
    func updateViewForEvent(event:Event){
        
        let attributedDescription = NSMutableAttributedString(string: event.shortDescription!)
        attributedDescription.setLineHeight(FontFactory.eventDescriptionLineHeight())
        attributedDescription.setFont(FontFactory.eventDescriptionFont())
        attributedDescription.setColor(UIColor.whiteColor())
        
        textView.attributedText = attributedDescription
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
