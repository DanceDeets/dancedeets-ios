//
//  EventDetailLocationCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//
import MapKit


class EventDetailLocationCell: UITableViewCell, UIGestureRecognizerDelegate,UIAlertViewDelegate {

    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var pinIcon: UIImageView!
    
    var event:Event?
    var directionAlert:UIAlertView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        pinIcon.tintColor = UIColor.whiteColor()
        venueLabel.numberOfLines = 0
        
        directionAlert = UIAlertView(title: "Get some directions to the venue?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Walk", "Drive")
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if(alertView == directionAlert && event != nil && event?.placemark != nil){
            if(buttonIndex == 1){
                let placemark = MKPlacemark(placemark: event!.placemark!)
                let mapItem:MKMapItem = MKMapItem(placemark: placemark)
                
                let launchOptions:[NSObject : AnyObject] = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
            }else if(buttonIndex == 2){
                let placemark = MKPlacemark(placemark: event!.placemark!)
                let mapItem:MKMapItem = MKMapItem(placemark: placemark)
                
                let launchOptions:[NSObject : AnyObject] = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
            }
        }
    }
    
    func mapTapped(){
        directionAlert?.show()
    }
    
    func updateViewForEvent(event:Event){
        let attributedDescription = NSMutableAttributedString(string: event.displayAddress)
        attributedDescription.setLineHeight(FontFactory.eventVenueLineHeight())
        attributedDescription.setFont(FontFactory.eventVenueFont())
        attributedDescription.setColor(UIColor.whiteColor())
        venueLabel.attributedText = attributedDescription
    }
}
