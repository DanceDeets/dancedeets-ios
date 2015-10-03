//
//  EventListItemTableViewCell.swift
//  DanceDeets
//
//  Created by David Xiang on 4/5/15.
//  Copyright (c) 2015 david.xiang. All rights reserved.
//

import UIKit

class EventListItemTableViewCell: UITableViewCell {
    
    let SEPARATOR_HORIZONTAL_INSETS:CGFloat = 12.0
    @IBOutlet var eventImageView:UIImageView!
    @IBOutlet var eventTitleLabel:UILabel!
    @IBOutlet var currentEvent:Event?
    @IBOutlet var danceIconImageView:UIImageView!
    @IBOutlet var clockIconImageView:UIImageView!
    @IBOutlet var pinIconImageView:UIImageView!
    @IBOutlet var eventCategoriesLabel:UILabel!
    @IBOutlet var eventTimeLabel:UILabel!
    @IBOutlet var eventVenueLabel:UILabel!

    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    func updateForEvent(event: Event) {
        currentEvent = event
        eventCategoriesLabel.text = "(" + event.categories.joinWithSeparator(", ") + ")"
        eventTitleLabel.text = event.title
        eventTimeLabel.text = event.displayTime
        if let venueDisplay = event.venue?.name{
            if (event.attendingCount != nil) {
                eventVenueLabel.text = venueDisplay + "  |  \(event.attendingCount!) attending"
            } else {
                eventVenueLabel.text = venueDisplay
            }
        }
        if imageHeightConstraint == nil {
            imageHeightConstraint = NSLayoutConstraint(item: eventImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0)
            imageHeightConstraint.priority = 999
            eventImageView!.addConstraints([imageHeightConstraint])
        }
        imageHeightConstraint.constant = event.eventImageHeight! / event.eventImageWidth! * eventImageView!.bounds.width
        contentView.layoutIfNeeded()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // No idea why these are necessary, since they are set in the NIB
        danceIconImageView.tintColor = UIColor.whiteColor()
        // No idea why we have to set this color directly, instead of copying another color
        // Seems there's some of magic going on with tintColor in multiple ways
        clockIconImageView.tintColor = UIColor(red: 0, green: 236, blue: 227, alpha: 1.0)
        pinIconImageView.tintColor = UIColor.whiteColor()
    }
}
