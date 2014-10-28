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
