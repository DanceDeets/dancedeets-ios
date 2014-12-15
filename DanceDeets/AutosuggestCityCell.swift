//
//  AutosuggestCityCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class AutosuggestCityCell: UITableViewCell {

    @IBOutlet weak var addLogoButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pinLogo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        cityLabel.font = FontFactory.standardTableLabelFont()
        cityLabel.textColor = UIColor.whiteColor()
        
        pinLogo.tintColor = ColorFactory.white50()
    }
    
}
