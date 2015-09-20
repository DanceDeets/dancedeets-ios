//
//  EventDetailMapCell.swift
//  DanceDeets
//
//  Created by David Xiang on 12/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import Foundation
import MapKit

class EventDetailMapCell:UITableViewCell
{
    var directionAlert:UIAlertView?
    var event:Event?
    var mapManager:MapManager?
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var eventMapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        directionButton.tintColor = UIColor.whiteColor()
        directionButton.backgroundColor = ColorFactory.lightBlue().colorWithAlphaComponent(0.5)
             directionButton.layer.cornerRadius = 3.0
          directionButton.layer.masksToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "getDirectionButtonTapped:")
        eventMapView.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func getDirectionButtonTapped(sender: AnyObject) {
        mapManager!.show()
    }
    
    func updateViewForEvent(event:Event){
        if(self.event == nil){
            self.event = event
            mapManager = MapManager(event: event)
            
            // setup map if possible
            if(event.geoloc != nil){
                let annotation:MKPointAnnotation = MKPointAnnotation()
                annotation.coordinate = event.geoloc!.coordinate
                eventMapView.addAnnotation(annotation)
                eventMapView.centerCoordinate = annotation.coordinate
                let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000,1000)
                eventMapView.setRegion(region,animated:true)
            }
        }
    }
    
}