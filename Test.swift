//
//  Test.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/25.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation
/*
func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
    let cell:EventCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as! EventCollectionViewCell
    let event = events[indexPath.row] as Event
    cell.updateForEvent(event)
    
    if let imageUrl = event.eventImageUrl{
        let imageRequest:NSURLRequest = NSURLRequest(URL: imageUrl)
        if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
            cell.eventCoverImage?.image = image
        }else{
            cell.eventCoverImage?.image = nil
            event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                // guard against cell reuse + async download
                if(event == cell.currentEvent){
                    if(image != nil){
                        cell.eventCoverImage?.image = image
                    }
                }
            })
        }
    }else{
        cell.eventCoverImage?.image = nil
    }
    
    // prefetch next image if possible
    if(indexPath.row < events.count - 1){
        let prefetchEvent:Event = events[indexPath.row + 1]
        if let imageUrl = prefetchEvent.eventImageUrl{
            let imageRequest:NSURLRequest = NSURLRequest(URL: imageUrl)
            if ImageCache.sharedInstance.cachedImageForRequest(imageRequest) ==  nil{
                prefetchEvent.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                })
            }
        }
    }
    
    return cell
}



// collection view
let flowLayout:UICollectionViewFlowLayout? = eventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
flowLayout?.sectionInset = UIEdgeInsetsZero
flowLayout?.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height)
flowLayout?.minimumInteritemSpacing = 0.0


*/