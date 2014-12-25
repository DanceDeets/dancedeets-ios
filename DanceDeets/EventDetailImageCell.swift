//
//  EventDetailImageCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/14/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import UIKit

class EventDetailImageCell: UITableViewCell
{
    
    @IBOutlet weak var eventImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    func updateViewForEvent(event:Event){
        
        if (event.eventImageUrl != nil){
            let imageRequest:NSURLRequest = NSURLRequest(URL: event.eventImageUrl!)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                eventImageView.image = image
            }else{
                event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if(image != nil && error == nil){
                        self.eventImageView.image = image
                    }
                })
            }
        }
        
        contentView.layoutIfNeeded()
    }
}