//
//  EventCollectionViewCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/26/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventCoverImage: UIImageView!
    @IBOutlet weak var eventCoverImageActivityIndicator: UIActivityIndicatorView!
    var currentEvent:Event?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        eventTitleLabel.font = FontFactory.eventHeadlineFont()
        eventTitleLabel.textColor = UIColor.whiteColor()
        eventTimeLabel.font = FontFactory.eventDateFont()
        eventTimeLabel.textColor =  ColorFactory.lightBlue()
        eventVenueLabel.textColor = UIColor.whiteColor()
        eventVenueLabel.font = FontFactory.eventVenueFont()
        /*
        mainView.layer.masksToBounds = false
        mainView.layer.shadowRadius = 4
        mainView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        mainView.layer.shadowColor = UIColor.blackColor().CGColor
        mainView.layer.shadowOpacity = 0.60
        
        titleLabel.font = UIFont(name:"BebasNeueBold",size: 24)
        venueLabel.font = UIFont(name: "BebasNeueBold", size: 20)
        descriptionLabel.font = UIFont(name: "Montserrat-Regular", size: 13)
        eventTimeLabel.font = UIFont(name:"Montserrat-Bold", size:14)
        eventTimeLabel.textColor = ColorFactory.lightBlue()
        */
    }
    
    
    func updateForEvent(event:Event){
        eventTitleLabel.text = event.title
        eventTimeLabel.text = event.displayTime
        eventVenueLabel.text = event.venue
       
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
