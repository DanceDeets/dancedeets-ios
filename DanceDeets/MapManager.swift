//
//  Wraps the "Get Directions" dialog and resulting open-in-maps functionality
//

import MapKit

public class MapManager
{
    public class func showOnMap(event: Event) {
        if let coordinate = event.geoloc?.coordinate {
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            let mapItem:MKMapItem = MKMapItem(placemark: placemark)
            mapItem.openInMapsWithLaunchOptions(nil)
        }
    }
}