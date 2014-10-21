//
//  MainAppLabel.swift
//  DanceDeets
//
//  Created by David Xiang on 9/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class MainAppLabel: UILabel {

    override func awakeFromNib() {
        super.awakeFromNib()
        let titleFont:UIFont = UIFont(name: "BebasNeueBold", size: 48)!
        self.font = titleFont
        self.textColor = UIColor.whiteColor()
    }

}
