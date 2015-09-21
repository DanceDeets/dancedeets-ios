//
//  EventCollectionViewCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/26/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var eventCoverImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventCategoriesLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventCoverImage: UIImageView!
    @IBOutlet weak var eventCoverImageActivityIndicator: UIActivityIndicatorView!
    var currentEvent:Event?
    
    @IBOutlet weak var danceIconImageView: UIImageView!
    @IBOutlet weak var pinIconImageView: UIImageView!
    @IBOutlet weak var clockIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clockIconImageView.tintColor = ColorFactory.lightBlue()
        pinIconImageView.tintColor = UIColor.whiteColor()
        danceIconImageView.tintColor = UIColor.whiteColor()
        
        eventTitleLabel.font = FontFactory.eventHeadlineFont()
        eventTitleLabel.textColor = UIColor.whiteColor()
        eventTitleLabel.numberOfLines = 2
        eventCategoriesLabel.textColor = UIColor.whiteColor()
        eventCategoriesLabel.font = FontFactory.eventVenueFont()
        eventTimeLabel.font = FontFactory.eventDateFont()
        eventTimeLabel.textColor =  ColorFactory.lightBlue()
        eventVenueLabel.textColor = UIColor.whiteColor()
        eventVenueLabel.font = FontFactory.eventVenueFont()
    }
    
    func updateForEvent(event:Event){
        
        /// need layout information early
        layoutIfNeeded()
        currentEvent = event
        
        eventTitleLabel.text = event.title
        eventTimeLabel.text = event.displayTime
        eventCategoriesLabel.text = "("+event.categories.joinWithSeparator(", ")+")"
        if let venueDisplay = event.venue{
            if(event.attendingCount != nil){
                eventVenueLabel.text = venueDisplay + "  |  \(event.attendingCount!) attending"
            }else{
                eventVenueLabel.text = venueDisplay
            }
        }
        
        eventCoverImage.contentMode = UIViewContentMode.ScaleAspectFill
        eventCoverImage.clipsToBounds = true
        
        // if height and width are available, re calc the constraints to keep the same aspect ratio
        if(event.eventImageHeight != nil && event.eventImageWidth != nil){
            let aspectRatio = event.eventImageWidth! / event.eventImageHeight!
            var calcHeight = eventCoverImage.frame.size.width / aspectRatio
            
            // height is capped at the width for consistency
            calcHeight = min(eventCoverImage.frame.size.width, calcHeight)
            eventCoverImageHeightConstraint.constant = calcHeight
        }else{
            // default to square
            eventCoverImageHeightConstraint.constant = eventCoverImage.frame.size.width
        }
        contentView.layoutIfNeeded()
    }
}
