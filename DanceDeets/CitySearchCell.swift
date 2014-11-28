//
//  CitySearchCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

class CitySearchCell: UITableViewCell {

    
    @IBOutlet weak var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        selectedBackgroundView = bgColorView
        
        cityLabel.font = FontFactory.standardTableLabelFont()
        cityLabel.textColor = UIColor.whiteColor()
    }
    
}
