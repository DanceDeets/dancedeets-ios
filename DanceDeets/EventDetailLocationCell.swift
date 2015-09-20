//
//  EventDetailLocationCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//
import MapKit


class EventDetailLocationCell: UITableViewCell {

    @IBOutlet weak var venueLabel: UILabel!
    
    func updateViewForEvent(event:Event){
        let attributedDescription = NSMutableAttributedString(string: event.displayAddress)
        attributedDescription.setLineHeight(FontFactory.eventVenueLineHeight())
        venueLabel.attributedText = attributedDescription
    }
}
