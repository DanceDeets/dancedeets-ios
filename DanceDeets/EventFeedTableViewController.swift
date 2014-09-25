//
//  EventFeedTableViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 9/20/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit

class EventFeedTableViewController: UITableViewController {
    var events:[Event] = []
    var currentCity:String? = String()
    let estimatedEventRowHeight:CGFloat = 400
    
    // event identifier -> image
    var imageCache = [String : UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image:UIImage(named:"background"))
        self.tableView.estimatedRowHeight = estimatedEventRowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let currentCity = "New York City"
        Event.loadEventsForCity(currentCity, completion: {(events:[Event]!, error) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.events = events
                self.tableView.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventTableViewCell", forIndexPath: indexPath) as EventTableViewCell
        let event = events[indexPath.row]
        cell.updateForEvent(event)
        
        if event.identifier != nil && event.eventImageUrl != nil{
            var image = imageCache[event.identifier!]
            
            if( image == nil ) {
                cell.eventPhoto?.image = nil
                // If the image does not exist, we need to download it
                var imgUrl = event.eventImageUrl!
                
                // Download an NSData representation of the image at the URL
                let request: NSURLRequest = NSURLRequest(URL: imgUrl)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        image = UIImage(data: data)
                        
                        // Store the image in to our cache
                        self.imageCache[event.identifier!] = image
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell{
                                cellToUpdate.eventPhoto?.image = image
                            }
                        })
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
                
            }
            else {
                cell.eventPhoto?.image = image
               // dispatch_async(dispatch_get_main_queue(), {
              //      if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? EventTableViewCell {
              //          cellToUpdate.eventPhoto?.image = image
              //      }
              //  })
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }


}
