//
//  Wraps the "Get Directions" dialog and resulting open-in-maps functionality
//

import MapKit

public class MapManager
{
    public class func showOnMap(event: Event) {
        if let coordinate = event.geoloc?.coordinate {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
                var encodedVenue:String
                if event.venue?.name != nil {
                    encodedVenue = event.venue!.name!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                } else {
                    encodedVenue = "\(coordinate.latitude),\(coordinate.longitude)"
                }

                let url = "comgooglemaps://?q=\(encodedVenue)&center=\(coordinate.latitude),\(coordinate.longitude)&zoom=15"
                UIApplication.sharedApplication().openURL(NSURL(string:url)!)
            }

            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: event.venue?.fullAddressDictionary)
            let mapItem:MKMapItem = MKMapItem(placemark: placemark)
            mapItem.openInMapsWithLaunchOptions(nil)
        }
    }
}