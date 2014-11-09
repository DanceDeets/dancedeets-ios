//
//  BasicSwitchTableCell.swift
//  DanceDeets
//
//  Created by David Xiang on 10/4/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

@objc protocol BasicSwitchTableCellDelegate
{
   optional func switchToggled(sender:UISwitch!) ->()
}

class BasicSwitchTableCell: UITableViewCell {
    
    var delegate:BasicSwitchTableCellDelegate?
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!

    @IBAction func toggleSwitchChanged(sender: AnyObject) {
        delegate?.switchToggled?(toggleSwitch)
    }
}
