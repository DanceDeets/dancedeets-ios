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
        // We launch the dialog manually, so that we can pass a view controller and use the sharesheet. For more info:
        // http://stackoverflow.com/questions/33086211/facebook-share-button-on-ios-9-opens-browser-instead-of-native-facebook-app/33871172#33871172
        FBSDKShareDialog.showFromViewController(parentViewController(), withContent: shareContent, delegate: nil)
    }
}
