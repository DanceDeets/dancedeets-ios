//
//  SendFeedbackCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/24/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

class SendFeedbackCell : UITableViewCell
{
    
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var feedbackIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        feedbackLabel.font = FontFactory.standardTableLabelFont()
        feedbackLabel.textColor = UIColor.whiteColor()
        
        feedbackIcon.tintColor = ColorFactory.white50()
    }
    
}