//
//  EventDetailTitleCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/8/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventDetailTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    func updateViewForEvent(event:Event){
        titleLabel.text = event.title
        contentView.layoutIfNeeded()
    }
}
