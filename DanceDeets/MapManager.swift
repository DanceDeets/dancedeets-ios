//
//  Wraps the "Get Directions" dialog and resulting open-in-maps functionality
//

import MapKit

public class MapManager : NSObject, UIAlertViewDelegate
{
    var event:Event?
    var directionAlert:UIAlertView?
    
    init(event: Event?) {
        super.init()
        self.event = event
        
        if #available(iOS 9.0, *) {
            directionAlert = UIAlertView(title: "Need directions? How are you getting there?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Walk", "Drive", "Public Transit")
        } else {
            directionAlert = UIAlertView(title: "Need directions? How are you getting there?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Walk", "Drive")
        }
    }
    
    public func show() {
        if event!.geoloc != nil {
            directionAlert!.show()
        }
    }
    
    // MARK: UIAlertViewDelegate
    public func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if(alertView == directionAlert){
            if let coordinate = event!.geoloc?.coordinate {
                let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                let mapItem:MKMapItem = MKMapItem(placemark: placemark)
                var transitStyle:String?
                if (buttonIndex == 1) {
                    transitStyle = MKLaunchOptionsDirectionsModeWalking
                } else if (buttonIndex == 2) {
                    transitStyle = MKLaunchOptionsDirectionsModeDriving
                } else if (buttonIndex == 3) {
                    if #available(iOS 9.0, *) {
                        transitStyle = MKLaunchOptionsDirectionsModeTransit
                    } else {
                        // Fallback on earlier versions
                    }
                }
                let launchOptions:[String : AnyObject] = [MKLaunchOptionsDirectionsModeKey:transitStyle!]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
            }
        }
    }
}