//
//  EventDetailCoverCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/8/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventDetailCoverCell: UITableViewCell {

    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        venueLabel.font = UIFont(name: "BebasNeueBold", size: 24)
        venueLabel.numberOfLines = 0
    }
    
}
