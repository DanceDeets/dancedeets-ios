//
//  EventDetailTimeCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventDetailTimeCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clockIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        timeLabel.font = FontFactory.eventDateFont()
        timeLabel.textColor =  ColorFactory.lightBlue()
        
        clockIcon.tintColor = ColorFactory.lightBlue()
    }
    
    func updateViewForEvent(event:Event){
        timeLabel.text = event.displayTime
        contentView.layoutIfNeeded()
    }
}
