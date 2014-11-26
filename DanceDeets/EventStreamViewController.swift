//
//  EventStreamViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 11/26/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventStreamViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let COLLECTION_VIEW_TOP_MARGIN:CGFloat = 70.0
    var events:[Event] = []
    
    // MARK: Outlets
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventCollectionView.delegate = self
        eventCollectionView.dataSource = self
        
        navigationTitle.textColor = UIColor.whiteColor()
        navigationTitle.font = FontFactory.navigationTitleFont()
        navigationTitle.text = "NEW YORK"
        
        eventCollectionView.layoutIfNeeded()
        let flowLayout:UICollectionViewFlowLayout? = eventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.sectionInset = UIEdgeInsetsZero
        flowLayout?.itemSize = CGSizeMake(view.frame.size.width,view.frame.size.height - COLLECTION_VIEW_TOP_MARGIN)
        flowLayout?.minimumInteritemSpacing = 0.0
        
        
        Event.loadEventsForCity("New York City", completion: {(events:[Event]!, error:NSError!) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // check response
                if(error != nil){
                    let errorAlert = UIAlertView(title: "Sorry", message: "There might have been a network problem. Check your connection", delegate: nil, cancelButtonTitle: "OK")
                    errorAlert.show()
                }else if(events.count == 0){
                    let noEventAlert = UIAlertView(title: "Sorry", message: "There doesn't seem to be any events in that area right now. Check back soon!", delegate: nil, cancelButtonTitle: "OK")
                    noEventAlert.show()
                }else{
                    self.events = events
                    self.eventCollectionView.reloadData()
                }
            })
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return events.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell:EventCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as? EventCollectionViewCell
        let event = events[indexPath.row] as Event
        cell?.updateForEvent(event)
        cell?.eventCoverImage?.image = nil
        
        if event.identifier != nil && event.eventImageUrl != nil{
            let imageRequest:NSURLRequest = NSURLRequest(URL: event.eventImageUrl!)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                cell?.eventCoverImage?.image = image
            }else{
                event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if(image != nil && error == nil){
                        cell?.eventCoverImage?.image = image
                    }
                })
            }
        }
        
        
        return cell!
    }

}
