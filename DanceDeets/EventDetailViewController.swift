//
//  EventDetailViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import EventKit

class EventDetailViewController: UIViewController {

    var event:Event?
    @IBOutlet weak var coverImageView: UIImageView!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nav bar buttons
        let image = UIImage(named: "calendar")
        var calendarButton = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: "calendarButtonTapped:")
        
        
        var shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        
        self.navigationItem.rightBarButtonItems = [shareButton, calendarButton]
        
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Action
    @IBAction func calendarButtonTapped(sender: AnyObject) {
        var store = EKEventStore()
        store.requestAccessToEntityType(EKEntityTypeEvent) { (granted:Bool, error:NSError!) -> Void in
            
            if(!granted && error != nil){
                return
            }
            
            var newEvent:EKEvent = EKEvent(eventStore: store)
            newEvent.title = self.event?.title
            newEvent.startDate = self.event?.startTime
            if let endTime = self.event?.endTime{
                newEvent.endDate = endTime
            }else{
                // default 2 hours
                newEvent.endDate = newEvent.startDate.dateByAddingTimeInterval(2*60*60)
            }
            newEvent.calendar = store.defaultCalendarForNewEvents
            var saveError:NSError?
            store.saveEvent(newEvent, span: EKSpanThisEvent, commit: true, error: &saveError)
            self.event?.savedEventId = newEvent.eventIdentifier
            
            if(saveError == nil){
                var message:String?
                if let title = self.event?.title{
                    message = "Added " + title + " to your calendar!"
                }else{
                    message = "Added to your calendar!"
                }
                dispatch_async(dispatch_get_main_queue(), {
                    let successAlert:UIAlertView = UIAlertView(title: "Dope", message: message, delegate: nil, cancelButtonTitle: "OK")
                    successAlert.show()
                })
            }
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        // Simple iOS action sheet
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

}
