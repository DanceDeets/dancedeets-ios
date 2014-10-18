//
//  EventTableViewCell.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 4;
        mainView.layer.masksToBounds = true
        venueLabel.font = UIFont(name:"BebasNeueBold",size: 22)
        eventTitleLabel.font = UIFont(name: "Montserrat-Bold", size: 14)
        descriptionLabel.font = UIFont(name: "Montserrat-Regular", size: 12)
        eventTimeLabel.font = UIFont(name:"Montserrat-Bold", size:14)
    }
    
    // Style the cell based on the event
    func updateForEvent(event:Event){
        eventTitleLabel.text = event.venue
        descriptionLabel.text = event.shortDescription
        venueLabel.text = event.title
        eventTimeLabel.text = event.displayTime
    }

}
