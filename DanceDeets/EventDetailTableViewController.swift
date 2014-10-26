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

class EventDetailTableViewController: UITableViewController {
    
    var event:Event?
    let geocoder:CLGeocoder = CLGeocoder()
    var coverImage:UIImageView?

    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventTagsLabel: UILabel!
    
    func backButtonTapped(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        if let imgUrl = event?.eventImageUrl{
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgUrl)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    let newImage:UIImage? = UIImage(data: data)
                    let height = newImage!.size.height
                    self.coverImage = UIImageView(image: newImage)
                    self.coverImage?.contentMode = UIViewContentMode.ScaleAspectFill
                    self.coverImage?.frame = CGRectMake(0, 0, self.tableView.frame.size.width, height)
                    
                    // Store the image in to our cache
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.tableHeaderView = self.coverImage
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        }
        */
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = event?.title
        self.eventTitleLabel.text = event?.title
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
    }

}
