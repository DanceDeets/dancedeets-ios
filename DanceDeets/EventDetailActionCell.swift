//
//  EventDetailActionCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/2/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import EventKit
import UIKit

class EventDetailActionCell: UITableViewCell,UIAlertViewDelegate {

    @IBOutlet weak var addToCalendarButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    var addCalendarAlert:UIAlertView?
    var facebookAlert:UIAlertView?
    var currentEvent:Event?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        addToCalendarButton.setBackgroundImage(UIImage(named: "button_calendar"), forState: UIControlState.Normal)
        addToCalendarButton.setBackgroundImage(UIImage(named: "button_calendar_blue"), forState: UIControlState.Highlighted)
        facebookButton.setBackgroundImage(UIImage(named:"button_facebook"), forState: UIControlState.Normal)
        
        addCalendarAlert = UIAlertView(title: "Want to add this event to your calendar?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        facebookAlert = UIAlertView(title: "RSVP on Facebook?", message: "", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
    }
    
    func updateViewForEvent(event:Event){
        currentEvent = event
    }
    @IBAction func addToCalendarButtonTapped(sender: AnyObject) {
        addCalendarAlert?.show()
    }
    
    @IBAction func facebookRSVPButtonTapped(sender: AnyObject) {
        facebookAlert?.show()
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if(alertView == addCalendarAlert)
        {
            if (buttonIndex == 1){
                var store = EKEventStore()
                store.requestAccessToEntityType(EKEntityTypeEvent) { (granted:Bool, error:NSError!) -> Void in
                    
                    if(!granted && error != nil){
                        return
                    }
                    
                    var newEvent:EKEvent = EKEvent(eventStore: store)
                    newEvent.title = self.currentEvent?.title
                    newEvent.startDate = self.currentEvent?.startTime
                    if let endTime = self.currentEvent?.endTime{
                        newEvent.endDate = endTime
                    }else{
                        // no end time parsed out, default 2 hours
                        newEvent.endDate = newEvent.startDate.dateByAddingTimeInterval(2*60*60)
                    }
                    newEvent.calendar = store.defaultCalendarForNewEvents
                    var saveError:NSError?
                    store.saveEvent(newEvent, span: EKSpanThisEvent, commit: true, error: &saveError)
                    self.currentEvent?.savedEventId = newEvent.eventIdentifier
                    
                    if(saveError == nil){
                        var message:String?
                        if let title = self.currentEvent?.title{
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
        }else if(alertView == facebookAlert){
            if(buttonIndex == 1){
                let graphPath = "/" + currentEvent!.identifier! + "/attending"
                FBRequestConnection.startWithGraphPath(graphPath, parameters: nil, HTTPMethod: "POST", completionHandler: { (conn:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                    if(error == nil){
                        let successAlert = UIAlertView(title: "RSVP'd on Facebook!", message: "",delegate:nil, cancelButtonTitle: "OK")
                        successAlert.show()
                    }else{
                        let errorAlert = UIAlertView(title: "Couldn't RSVP right now, try again later.", message: "",delegate:nil, cancelButtonTitle: "OK")
                        errorAlert.show()
                    }
                })
            }
        }
    }
}