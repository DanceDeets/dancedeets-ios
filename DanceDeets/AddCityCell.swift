//
//  AddCityCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/24/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation

class AddCityCell : UITableViewCell
{
    
    @IBOutlet weak var addCityLabel: UILabel!
    @IBOutlet weak var cityIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        cityIcon.tintColor = ColorFactory.white50()
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        selectedBackgroundView = bgColorView
        
        addCityLabel.font = FontFactory.standardTableLabelFont()
        addCityLabel.textColor = UIColor.whiteColor()
        
        addCityLabel.tintColor = ColorFactory.white50()
    }
    
}