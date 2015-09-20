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
    @IBOutlet weak var pinIcon: UIImageView!
    
    var mapManager:MapManager?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        pinIcon.tintColor = UIColor.whiteColor()
        venueLabel.numberOfLines = 0
    }

    func mapTapped(){
        mapManager!.show()
    }
    
    func updateViewForEvent(event:Event){
        mapManager = MapManager(event: event)
        print(event.displayAddress)
        let attributedDescription = NSMutableAttributedString(string: event.displayAddress)
        attributedDescription.setLineHeight(FontFactory.eventVenueLineHeight())
        attributedDescription.setFont(FontFactory.eventVenueFont())
        attributedDescription.setColor(UIColor.whiteColor())
        venueLabel.attributedText = attributedDescription
    }
}
