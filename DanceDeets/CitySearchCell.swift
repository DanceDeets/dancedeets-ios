//
//  CitySearchCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

class CitySearchCell: UITableViewCell {
    
    var settingsVC:SettingsViewController?
    
    @IBOutlet weak var pinLogo: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        settingsVC?.deleteCityRow(cityLabel.text!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        selectedBackgroundView = bgColorView
        
        cityLabel.font = FontFactory.standardTableLabelFont()
        cityLabel.textColor = UIColor.whiteColor()
        
        pinLogo.tintColor = ColorFactory.white50()
    }
    
}
