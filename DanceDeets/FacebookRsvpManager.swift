//
//  FacebookRsvpManager.swift
//  DanceDeets
//
//  Created by Mike Lambert on 2015/09/24.
//  Copyright © 2015 Mike Lambert. All rights reserved.
//

import Foundation

public class FacebookRsvpManager {

    public enum RSVP: String {
        case Attending = "attending"
        case Maybe = "maybe"
        case Declined = "declined"
    }
    
    public class func setRsvpOnFacebook(event: Event, rsvp: RSVP, parentController: UIViewController) {
        let token = FBSDKAccessToken.currentAccessToken()
        if (token.hasGranted("rsvp_event")) {
            rsvpFacebook(event, withRsvp: rsvp)
        } else {
            let login = FBSDKLoginManager()
            login.logInWithPublishPermissions(["rsvp_event"], fromViewController: parentController, handler: { (login:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if (error == nil && token.hasGranted("rsvp_event")) {
                    rsvpFacebook(event, withRsvp: rsvp)
                } else {
                    let errorAlert = UIAlertView(title: "Permissions weren't granted.", message: "", delegate:nil, cancelButtonTitle: "OK")
                    errorAlert.show()
                }
            })
        }
    }
    
    class func rsvpFacebook(event: Event, withRsvp rsvp: RSVP) {
        let graphPath = "/" + event.id! + "/" + rsvp.rawValue
        let request = FBSDKGraphRequest(graphPath: graphPath, parameters: nil, HTTPMethod: "POST")
        request.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection!, obj: AnyObject!, error: NSError!) -> Void in
            if(error == nil){
                let successAlert = UIAlertView(title: "RSVP'd on Facebook!", message: "", delegate:nil, cancelButtonTitle: "OK")
                successAlert.show()
            }else{
                print(error)
                let errorAlert = UIAlertView(title: "Couldn't RSVP right now, try again later.", message: "", delegate:nil, cancelButtonTitle: "OK")
                errorAlert.show()
            }
        }
    }
}