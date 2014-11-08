//
//  EventDetailTableViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/26/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class EventDetailTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var event:Event?

    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventTagsLabel: UILabel!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIView()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = event?.title
        
        // TODO dont need to do this every time
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        event?.getMoreDetails({ (error:NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if(error != nil){
                    self.tableView.reloadData()
                }
            })
        })
        
    }
    
    // MARK: Action
    @IBAction func shareButtonTapped(sender: AnyObject) {
        var sharingItems:[AnyObject] = []
        
        if let title = event?.title{
            sharingItems.append("Check out this event: " + title)
        }
        
        if let url = event?.facebookUrl{
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITableViewDataSource 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCoverCell", forIndexPath: indexPath) as EventDetailCoverCell
            let imageRequest = NSURLRequest(URL: event!.eventImageUrl!)
            cell.venueLabel.text = event?.venue
            cell.contentView.setNeedsLayout()
            if let image:UIImage? = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                cell.coverImageView.image = image
            }else{
                event!.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if(image != nil && error == nil){
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell{
                            cellToUpdate.eventPhoto?.image = image
                        }
                    }
                })
            }
            return cell
        }else{
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "default")
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: UITableViewDelegate
 

}
