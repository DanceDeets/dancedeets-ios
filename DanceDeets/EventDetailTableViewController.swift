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

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventTagsLabel: UILabel!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIView()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.eventVenueLabel.text = event?.venue
        self.descriptionLabel.text = event?.shortDescription
        self.eventTagsLabel.text = event?.tagString
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd 'at' h:mm a"
        
        if let startTime = event?.startTime{
            eventStartTimeLabel.text = formatter.stringFromDate(startTime)
        }else{
            eventStartTimeLabel.text = ""
        }
        if let endTime = event?.endTime{
            eventEndTimeLabel.text = formatter.stringFromDate(endTime)
        }else{
            eventEndTimeLabel.text = ""
        }
        
        eventVenueLabel.font = UIFont(name: "BebasNeueBold", size: 20)
        
        self.title = event?.title
        
        // TODO Use cached image from previous controller
        let request: NSURLRequest = NSURLRequest(URL: event!.eventImageUrl!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                let newImage = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue(), {
                    self.coverImageView.image = newImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCoverCell", forIndexPath: indexPath) as UITableViewCell
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
    
    // MARK: UITableViewDelegate
    
 

}
