//
//  EventDetailCell
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit

class EventDetailCell: UICollectionViewCell {
    
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 15.0

    var ASPECT_RATIO:CGFloat = 1.0
    
    var event:Event!
    var initialImage:UIImage?
    
    var addToCalendar:AddToCalendar?

    var tableView:UITableView?

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var eventCoverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var eventCategoriesLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UITextView!
    @IBOutlet weak var eventMapView: MKMapView!

    @IBOutlet weak var eventCoverImageViewHeightConstraint: NSLayoutConstraint!

    func setupEvent(event: Event) {
        self.event = event
        // Reset scroll position on setup, in case we are recycling a cell
        scrollView.setContentOffset(CGPoint(x:0, y:0), animated: false)

        // Initialize display objects

        eventTitleLabel.text = event.title!
        eventTitleLabel.numberOfLines = 0
        eventTitleLabel.lineBreakMode = .ByWordWrapping
        eventTitleLabel.frame = CGRectMake(
            eventTitleLabel.frame.origin.x, eventTitleLabel.frame.origin.y,
            eventTitleLabel.frame.size.width, 200);
        eventTimeLabel.text = event.displayTime
        eventVenueLabel.text = event.displayAddress

        eventCategoriesLabel.text = "("+event.categories.joinWithSeparator(", ")+")"
        let attributedDescription = NSMutableAttributedString(string: event.shortDescription!)
        // TODO: why is setLineHeight and textContainerInset both required to make this fit correctly?
        attributedDescription.setLineHeight(18)
        attributedDescription.setFont(eventDescriptionLabel.font!)
        attributedDescription.setColor(eventDescriptionLabel.textColor!)
        eventDescriptionLabel.attributedText = attributedDescription

        let mapGesture = UITapGestureRecognizer(target: self, action: "mapTapped:")
        eventMapView.addGestureRecognizer(mapGesture)
        let venueGesture = UITapGestureRecognizer(target: self, action: "mapTapped:")
        eventVenueLabel.addGestureRecognizer(venueGesture)
        let imageGesture = UITapGestureRecognizer(target: self, action: "imageTapped:")
        eventCoverImageView.addGestureRecognizer(imageGesture)

        // setup map if possible
        if (event.geoloc != nil) {
            let annotation:MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = event.geoloc!.coordinate
            eventMapView.addAnnotation(annotation)
            eventMapView.centerCoordinate = annotation.coordinate
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000,1000)
            eventMapView.setRegion(region, animated:false)
        }
        
        // set to initial image first, this may be a smaller image if coming from list view
        eventCoverImageView.image = initialImage
        if let url = event.eventImageUrl {
            // hero image for detail view is the big image
            let imageRequest:NSURLRequest = NSURLRequest(URL: url)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                eventCoverImageView.image = image
            } else {
                event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if (image != nil && error == nil) {
                        self.eventCoverImageView.image = image
                    }
                })
            }
        }

        // aspect ratio if available, capped at 1:1 to prevent super tall images
        if event.eventImageHeight != nil && event.eventImageWidth != nil {
            ASPECT_RATIO = min(1.0, event.eventImageHeight! / event.eventImageWidth!)
        }
        eventCoverImageViewHeightConstraint.constant = frame.size.width * ASPECT_RATIO
        print(ASPECT_RATIO)
        print("Height: ", eventCoverImageViewHeightConstraint.constant)
        layoutIfNeeded()
    }

    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    // MARK: Buttons
    func shareButtonTapped(sender: AnyObject) {
        if (event != nil) {
            AnalyticsUtil.track("Share Event", withEvent: event)
            let activityViewController = UIActivityViewController(activityItems: event!.createSharingItems(), applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            self.parentViewController()!.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }

    func imageTapped(sender: AnyObject?) {
        AppDelegate.sharedInstance().allowLandscape = true
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.parentViewController()!.performSegueWithIdentifier("fullScreenImageSegue", sender: self)
        })
    }

    func mapTapped(sender: AnyObject?) {
        AnalyticsUtil.track("View on Map", withEvent: event)
        MapManager.showOnMap(event!)
    }
    
    func facebookTapped(sender: AnyObject) {
        if (event != nil) {
            AnalyticsUtil.track("Open in Facebook", withEvent: event)
            let urlString:String?
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "fb://")!) {
                urlString = String(format: "fb://profile/%@", event.id!);
            } else {
                urlString = String(format: "https://www.facebook.com/events/%@", event.id!);
            }
            let url = NSURL(string: urlString!)
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    func calendarTapped(sender: AnyObject) {
        AnalyticsUtil.track("Add to Calendar", withEvent: event)
        addToCalendar = AddToCalendar(event: event)
        addToCalendar!.addToCalendar()
    }
    
    func rsvpTapped(sender: AnyObject) {
        let rsvp = FacebookRsvpManager.RSVP.Attending
        AnalyticsUtil.track("RSVP", withEvent: event, ["RSVP Value": rsvp.rawValue])
        FacebookRsvpManager.rsvpFacebook( event, withRsvp: rsvp)
    }
}
