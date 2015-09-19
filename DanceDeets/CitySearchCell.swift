//
//  CitySearchCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

class CitySearchCell: SettingsCell {
    
    var settingsVC:SettingsViewController?
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func deleteButtonTapped(sender: AnyObject) {
        settingsVC?.deleteCityRow(label.text!)
    }
}
