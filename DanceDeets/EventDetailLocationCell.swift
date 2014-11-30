//
//  EventDetailLocationCell.swift
//  DanceDeets
//
//  Created by David Xiang on 11/15/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//
import MapKit


class EventDetailLocationCell: UITableViewCell, UIGestureRecognizerDelegate,UIAlertViewDelegate {

    @IBOutlet weak var addressLine2: UILabel!
    @IBOutlet weak var addressLine1: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var getDirectionButton: UIButton!
    
    //@IBOutlet weak var mapView: MKMapView!
    
    var event:Event?
    var directionAlert:UIAlertView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
      //  self.backgroundColor = UIColor.redColor()
        selectionStyle = UITableViewCellSelectionStyle.None
        
        venueLabel.numberOfLines = 0
      //  venueLabel.backgroundColor = UIColor.greenColor()
       // let mapTapped = UITapGestureRecognizer(target: self, action: "mapTapped")
        //mapView.addGestureRecognizer(mapTapped)
        
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
        
            if(event.displayAddress != nil){
                var attributedDescription = NSMutableAttributedString(string: event.displayAddress!)
                attributedDescription.setLineHeight(FontFactory.eventVenueLineHeight())
                attributedDescription.setFont(FontFactory.eventVenueFont())
                attributedDescription.setColor(UIColor.whiteColor())
                venueLabel.attributedText = attributedDescription
                println(venueLabel.frame)
            }
            
            /*
            if(event.placemark != nil && event.placemark?.addressDictionary != nil){
                
                var line1:String?
                if let lines = event.placemark?.addressDictionary["FormattedAddressLines"] as? [String]{
                    if lines.count >= 2{
                       // let line1String = event.placemark!.subThoroughfare + " " + event.placemark!.thoroughfare
                        var line1 = NSMutableAttributedString(string:lines[0])
                        line1.setLineHeight(EventDetailLocationCell.venueLineHeight())
                        line1.setFont(EventDetailLocationCell.venueFont())
                        line1.setColor(ColorFactory.darkYellow())
                        addressLine1.attributedText = line1
                        addressLine1.sizeToFit()
                        
                        //let line2String = event.placemark!.locality + ", " +
                          //  event.placemark!.administrativeArea + ", " +
                           // event.placemark!.postalCode
                        var line2 = NSMutableAttributedString(string:lines[1])
                        line2.setLineHeight(EventDetailLocationCell.venueLineHeight())
                        line2.setFont(EventDetailLocationCell.venueFont())
                        line2.setColor(ColorFactory.darkYellow())
                        addressLine2.attributedText = line2
                        addressLine2.sizeToFit()
                    }
                }
                
          
                
                if(event.geoloc != nil){
                    let annotation:MKPointAnnotation = MKPointAnnotation()
                    annotation.setCoordinate(event.geoloc!.coordinate)
                   // mapView.addAnnotation(annotation)
                   // mapView.centerCoordinate = event.geoloc!.coordinate
                    
                    let region = MKCoordinateRegionMakeWithDistance(event.geoloc!.coordinate, 1500,1500)
                   // mapView.setRegion(region,animated:false)
                    
                }
                
            }
*/
            contentView.setNeedsLayout()
            contentView.layoutIfNeeded()
            layoutIfNeeded()
    }
}
