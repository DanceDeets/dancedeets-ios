//
//  EventDetailMapCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import MapKit

class EventDetailMapCell:UITableViewCell, UIAlertViewDelegate
{
    var directionAlert:UIAlertView?
    var currentEvent:Event?
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var eventMapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        directionButton.tintColor = UIColor.blackColor()
        directionButton.backgroundColor = ColorFactory.lightBlue().colorWithAlphaComponent(0.5)
             directionButton.layer.cornerRadius = 3.0
          directionButton.layer.masksToBounds = true
        directionAlert = UIAlertView(title: "Get some directions to the venue?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Walk", "Drive")
        let tapGesture = UITapGestureRecognizer(target: self, action: "getDirectionButtonTapped:")
        eventMapView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func getDirectionButtonTapped(sender: AnyObject) {
        directionAlert?.show()
    }
    
    func updateViewForEvent(event:Event){
        if(currentEvent == nil){
            currentEvent = event
            
            // setup map if possible
            if(event.geoloc != nil){
                let annotation:MKPointAnnotation = MKPointAnnotation()
                annotation.setCoordinate(event.geoloc!.coordinate)
                eventMapView.addAnnotation(annotation)
                eventMapView.centerCoordinate = annotation.coordinate
                let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000,1000)
                eventMapView.setRegion(region,animated:true)
            }
        }
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if(currentEvent != nil && currentEvent?.placemark != nil){
            if(alertView == directionAlert){
                if(buttonIndex == 1){
                    let placemark = MKPlacemark(placemark: currentEvent!.placemark!)
                    let mapItem:MKMapItem = MKMapItem(placemark: placemark)
                    
                    let launchOptions:[NSObject : AnyObject] = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking]
                    mapItem.openInMapsWithLaunchOptions(launchOptions)
                }else if(buttonIndex == 2){
                    let placemark = MKPlacemark(placemark: currentEvent!.placemark!)
                    let mapItem:MKMapItem = MKMapItem(placemark: placemark)
                    
                    let launchOptions:[NSObject : AnyObject] = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMapsWithLaunchOptions(launchOptions)
                }
                
            }
        }
    }
    
}