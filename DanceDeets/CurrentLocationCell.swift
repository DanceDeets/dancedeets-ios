//
//  CurrentLocationCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//


class CurrentLocationCell: UITableViewCell {

    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var nearMeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        selectedBackgroundView = bgColorView
        
        currentLocationLabel.font = FontFactory.standardTableLabelFont()
        currentLocationLabel.textColor = UIColor.whiteColor()
    }
    
}
