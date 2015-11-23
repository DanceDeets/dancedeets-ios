//
//  EventShareButton.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/11/23.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import FBSDKShareKit
import Foundation

public class EventShareButton: FBSDKShareButton {

    func _share(sender: AnyObject) {
        FBSDKShareDialog.showFromViewController(parentViewController(), withContent: shareContent, delegate: nil)
    }
}
