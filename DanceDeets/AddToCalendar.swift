//
//  AddToCalendar.swift
//  DanceDeets
//
//  Created by LambertMike on 2015/09/24.
//  Copyright © 2015年 david.xiang. All rights reserved.
//

import Foundation
import EventKit

public class AddToCalendar: NSObject, UIAlertViewDelegate {
    
    var permissionAlert: UIAlertView?
    var addCalendarAlert: UIAlertView?
    var event: Event
    
    init(event: Event) {
        self.event = event
    }

    public func addToCalendar() {
        let store = EKEventStore()
        store.requestAccessToEntityType(EKEntityType.Event) { (granted:Bool, error:NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (!granted || error != nil) {
                    self.permissionAlert = UIAlertView(title: "DanceDeets doesn't have permission to do that.", message: "Please enable calendar permissions in Settings->DanceDeets", delegate: self, cancelButtonTitle: "Not Now", otherButtonTitles: "Open Settings")
                    self.permissionAlert!.show()
                } else {
                    self.addCalendarAlert = UIAlertView(title: "Added to your calendar!", message: "", delegate: self, cancelButtonTitle: "Undo", otherButtonTitles: "OK")
                    self.addCalendarAlert!.show()
                }
            })
        }
    }
    
    // MARK: UIAlertViewDelegate
    @objc public func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if (alertView == self.addCalendarAlert)
        {
            if (buttonIndex == 1) {
                let store = EKEventStore()
                store.requestAccessToEntityType(EKEntityType.Event) { (granted: Bool, error: NSError?) -> Void in
                    if (!granted && error != nil) {
                        return
                    }
                    let newEvent:EKEvent = EKEvent(eventStore: store)
                    newEvent.title = (self.event.title)!
                    newEvent.startDate = (self.event.startTime)!
                    if let endTime = self.event.endTime{
                        newEvent.endDate = endTime
                    } else {
                        // no end time parsed out, default 2 hours
                        newEvent.endDate = newEvent.startDate.dateByAddingTimeInterval(2*60*60)
                    }
                    newEvent.calendar = store.defaultCalendarForNewEvents
                    var saveError:NSError?
                    do {
                        try store.saveEvent(newEvent, span: EKSpan.ThisEvent, commit: true)
                    } catch let error as NSError {
                        saveError = error
                    } catch {
                        fatalError()
                    }
                    print(saveError)
                }
            }
        } else if (alertView == permissionAlert) {
            if (buttonIndex == 1) {
                let url = NSURL(string:UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(url!)
            }
        }
    }
}