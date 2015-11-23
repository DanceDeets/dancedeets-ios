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
        eventTitleLabel.text = event.title!
        eventTimeLabel.text = event.displayTime
        if let venueDisplay = event.venue?.formattedNameAndCity() {
            if (event.attendingCount != nil) {
                eventVenueLabel.text = venueDisplay + "\n" + String.localizedStringWithFormat(NSLocalizedString("%d attending", comment: "Event Listing"), event.attendingCount!)
            } else {
                eventVenueLabel.text = venueDisplay
            }
        }
        if imageHeightConstraint == nil {
            imageHeightConstraint = NSLayoutConstraint(item: eventImageView!, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0)
            imageHeightConstraint.priority = 999
            eventImageView!.addConstraints([imageHeightConstraint])
        }
        if (event.eventImageWidth != nil && event.eventImageHeight != nil) {
            imageHeightConstraint.constant = event.eventImageHeight! / event.eventImageWidth! * eventImageView!.bounds.width
        } else {
            imageHeightConstraint.constant = 0
        }
        contentView.layoutIfNeeded()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // This must be set in code (not Interface Builder), according to:
        // http://stackoverflow.com/questions/18878258/uitableviewcell-show-white-background-and-cannot-be-modified-on-ios7
        // The IB setting works fine on iPhone, but on iPad the following line proves necessary.
        backgroundColor = UIColor.clearColor()

        // No idea why these are necessary, since they are set in the NIB
        danceIconImageView.tintColor = UIColor.whiteColor()
        // No idea why we have to set this color directly, instead of copying another color
        // Seems there's some of magic going on with tintColor in multiple ways
        clockIconImageView.tintColor = UIColor(red: 192.0/255, green: 1.0, blue: 192.0/255, alpha: 1.0)
        pinIconImageView.tintColor = UIColor.whiteColor()
    }
}
