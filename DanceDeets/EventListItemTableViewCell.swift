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
        contentView.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // No idea why these are necessary, since they are set in the NIB
        danceIconImageView.tintColor = UIColor.whiteColor()
        clockIconImageView.tintColor = ColorFactory.lightBlue()
        pinIconImageView.tintColor = UIColor.whiteColor()
    }
}
