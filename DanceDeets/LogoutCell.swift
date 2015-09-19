//
//  LogoutCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/24/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation


class LogoutCell : UITableViewCell
{
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var logoutIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        selectedBackgroundView = bgColorView
        
        logoutLabel.font = FontFactory.standardTableLabelFont()
        logoutLabel.textColor = UIColor.whiteColor()
        
        logoutIcon.tintColor = ColorFactory.white50()
    }
    
}