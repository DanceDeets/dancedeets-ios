//
//  EventTableViewCell.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.masksToBounds = false
        mainView.layer.shadowRadius = 3
        mainView.layer.shadowOffset = CGSize(width: 3.0, height: 5.0)
        mainView.layer.shadowColor = UIColor.blackColor().CGColor
        mainView.layer.shadowOpacity = 0.80
        
        titleLabel.font = UIFont(name:"BebasNeueBold",size: 26)
        venueLabel.font = UIFont(name: "BebasNeueBold", size: 22)
        descriptionLabel.font = UIFont(name: "Montserrat-Regular", size: 13)
        eventTimeLabel.font = UIFont(name:"Montserrat-Bold", size:14)
    }
    
    // Style the cell based on the event
    func updateForEvent(event:Event){
        venueLabel.text = event.venue
        descriptionLabel.text = event.shortDescription
        titleLabel.text = event.title
        eventTimeLabel.text = event.displayTime
    }

}
