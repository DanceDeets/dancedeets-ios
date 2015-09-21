//
//  SettingsCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/24/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

class SettingsCell : UITableViewCell
{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        selectedBackgroundView = bgColorView
        
        label.font = FontFactory.standardTableLabelFont()
        label.textColor = UIColor.whiteColor()
        label.tintColor = ColorFactory.white50()
        icon.tintColor = ColorFactory.white50()
    }
    
}