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
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventCoverImage: UIImageView!
    @IBOutlet weak var eventCoverImageActivityIndicator: UIActivityIndicatorView!
    var currentEvent:Event?
    
    @IBOutlet weak var pinIconImageView: UIImageView!
    @IBOutlet weak var clockIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clockIconImageView.tintColor = ColorFactory.lightBlue()
        pinIconImageView.tintColor = UIColor.whiteColor()
        
        eventTitleLabel.font = FontFactory.eventHeadlineFont()
        eventTitleLabel.textColor = UIColor.whiteColor()
        eventTimeLabel.font = FontFactory.eventDateFont()
        eventTimeLabel.textColor =  ColorFactory.lightBlue()
        eventVenueLabel.textColor = UIColor.whiteColor()
        eventVenueLabel.font = FontFactory.eventVenueFont()
    }
    
    func updateForEvent(event:Event){
        layoutIfNeeded()
        
        eventTitleLabel.text = event.title
        eventTimeLabel.text = event.displayTime
        eventVenueLabel.text = event.venue
        
        eventCoverImageHeightConstraint.constant = eventCoverImage.frame.size.width
        eventCoverImage.contentMode = UIViewContentMode.ScaleAspectFill
        
        // if height and width are available, re calc the constraints to keep a nice aspect ratio
        if(event.eventImageHeight != nil && event.eventImageWidth != nil){
            let aspectRatio = event.eventImageWidth! / event.eventImageHeight!
            let calcHeight = eventCoverImage.frame.size.width / aspectRatio
            eventCoverImageHeightConstraint.constant = calcHeight
            eventCoverImage.contentMode = UIViewContentMode.ScaleToFill
        }else{
            eventCoverImageHeightConstraint.constant = eventCoverImage.frame.size.width
            eventCoverImage.contentMode = UIViewContentMode.ScaleAspectFill
        }
       
        contentView.layoutIfNeeded()
        
        // tricky here, we need to assign the correct aspect ratio, then see if the
        // bottom venue label runs off the edge. If it's taking up too much space, need 
        // to re layout and cap the height so everything fits
        let maxYOffset = eventVenueLabel.frame.origin.y + eventVenueLabel.frame.size.height + 10
        if(maxYOffset > contentView.frame.size.height){
            eventCoverImageHeightConstraint.constant -= (maxYOffset - contentView.frame.size.height)
            contentView.layoutIfNeeded()
        }
    }
}
