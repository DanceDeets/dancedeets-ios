//
//  OneboxListItemTableViewCell.swift
//  DanceDeets
//
//  Created by David Xiang on 4/5/15.
//  Copyright (c) 2015 Mike Lambert. All rights reserved.
//

import UIKit

class OneboxListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var linkTitleView: UILabel!

    func updateForOneboxLink(oneboxLink: OneboxLink) {
        linkTitleView.text = oneboxLink.title        
    }
}
