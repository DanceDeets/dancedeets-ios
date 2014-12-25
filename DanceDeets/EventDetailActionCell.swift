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
    var permissionAlert:UIAlertView?
    var currentEvent:Event?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        addToCalendarButton.setBackgroundImage(UIImage(named: "button_calendar"), forState: UIControlState.Normal)
        addToCalendarButton.setBackgroundImage(UIImage(named: "button_calendar_blue"), forState: UIControlState.Highlighted)
        facebookButton.setBackgroundImage(UIImage(named:"button_facebook"), forState: UIControlState.Normal)
        
        addCalendarAlert = UIAlertView(title: "Added to your calendar!", message: "", delegate: self, cancelButtonTitle: "Undo", otherButtonTitles: "OK")
        permissionAlert = UIAlertView(title: "Dance Deets doesn't have permission to do that.", message: "Please enable calendar permissions in Settings->Dance Deets", delegate: self, cancelButtonTitle: "Not Now", otherButtonTitles: "Open Settings")
    }
    
    func updateViewForEvent(event:Event){
        currentEvent = event
    }
    
    @IBAction func addToCalendarButtonTapped(sender: AnyObject) {
        var store = EKEventStore()
        store.requestAccessToEntityType(EKEntityTypeEvent) { (granted:Bool, error:NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if(!granted || error != nil){
                    self.permissionAlert?.show()
                }else{
                    self.addCalendarAlert?.show()
                }
            })
        }
    }
    
    @IBAction func facebookRSVPButtonTapped(sender: AnyObject) {
        if(FBSession.activeSession().hasGranted("rsvp_event")){
            rsvpFacebook()
        }else{
            FBSession.activeSession().requestNewPublishPermissions(["rsvp_event"], defaultAudience: FBSessionDefaultAudience.OnlyMe) { (session:FBSession!, error:NSError!) -> Void in
                if(error == nil && session.hasGranted("rsvp_event") == true){
                    self.rsvpFacebook()
                }else{
                    let errorAlert = UIAlertView(title: "Permissions weren't granted.", message: "",delegate:nil, cancelButtonTitle: "OK")
                    errorAlert.show()
                }
                
            }
        }
    }
    
    func rsvpFacebook(){
        let graphPath = "/" + self.currentEvent!.identifier! + "/attending"
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
                }
            }
        }else if(alertView == permissionAlert){
            if(buttonIndex == 1){
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            }
        }
    }
}