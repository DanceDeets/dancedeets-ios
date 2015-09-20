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
        textView.textContainerInset = UIEdgeInsetsZero
    }

    func updateViewForEvent(event:Event){
        
        let attributedDescription = NSMutableAttributedString(string: event.shortDescription!)
        // TODO: why is setLineHeight and textContainerInset both required to make this fit correctly?
        attributedDescription.setLineHeight(18)
        attributedDescription.setFont(textView.font!)
        attributedDescription.setColor(textView.textColor!)

        textView.attributedText = attributedDescription
        contentView.layoutIfNeeded()
    }
}
