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

    @IBOutlet weak var eventStartTimeLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventEndTimeLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = event?.title
        self.eventTitleLabel.text = event?.title
        self.eventVenueLabel.text = event?.venue
        self.descriptionLabel.text = event?.shortDescription
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd 'at' h:mm a"
        
        if let startTime = event?.startTime{
            eventStartTimeLabel.text = formatter.stringFromDate(startTime)
        }else{
            eventStartTimeLabel.text = "Unknown"
        }
        if let endTime = event?.endTime{
            eventEndTimeLabel.text = formatter.stringFromDate(endTime)
        }else{
            eventEndTimeLabel.text = "Unknown"
        }
        
        // try to detect an address in the description
        var dataError:NSError?
        let addressDetector:NSDataDetector? = NSDataDetector(types: NSTextCheckingType.Address.toRaw(), error: &dataError)
        
        
        var streetAddress:String?
        if let eventDescription = event?.shortDescription {
            addressDetector?.enumerateMatchesInString(eventDescription, options: nil, range: NSMakeRange(0, eventDescription.length), usingBlock: { (result:NSTextCheckingResult!, flags:NSMatchingFlags, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
                println(result)
                println(result.components)
                
                if let streetString: AnyObject = result.components?[NSTextCheckingStreetKey] {
                    streetAddress = streetString as? String
                    stop.memory = true
                }
            })
        }
        
        if streetAddress != nil{
            println(streetAddress)
            
        }

    }

}
