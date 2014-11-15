//
//  EventDetailCoverCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/8/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventDetailCoverCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
   
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont(name: "BebasNeueBold", size: 50)
    }
    
    func updateViewForEvent(event:Event){
        titleLabel.text = event.title
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
}
