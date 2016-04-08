//
//  EventDetailCell
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import FBSDKShareKit
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

    var linkContent:FBSDKShareLinkContent!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var sourceIconView: UIImageView!
    @IBOutlet weak var danceIconView: UIImageView!
    @IBOutlet weak var clockIconView: UIImageView!
    @IBOutlet weak var rsvpIconView: UIImageView!
    @IBOutlet weak var pinIconView: UIImageView!

    @IBOutlet weak var eventCoverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventSourceLabel: UILabel!
    @IBOutlet weak var eventCategoriesLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventRsvpLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UITextView!
    @IBOutlet weak var eventMapView: MKMapView!

    @IBOutlet weak var eventShareButton: EventShareButton!

    @IBOutlet weak var eventCoverImageViewHeightConstraint: NSLayoutConstraint!

    func setupEvent(event: Event) {
        self.event = event

        // Initialize display objects

        eventTitleLabel.text = event.title!
        eventTitleLabel.numberOfLines = 0
        eventTitleLabel.lineBreakMode = .ByWordWrapping
        if event.isFbEvent() {
            sourceIconView.image = UIImage(named: "facebookIcon")
        } else {
            sourceIconView.image = UIImage(named: "browserIcon")
        }
        eventSourceLabel.text = String.localizedStringWithFormat(NSLocalizedString("Source: %@", comment: "Link to event source"), event.sourceName!)
        eventTimeLabel.text = event.displayTime
        eventRsvpLabel.text = event.rsvpSummary()
        eventVenueLabel.text = event.displayAddress

        eventCategoriesLabel.text = "("+event.categories.joinWithSeparator(", ")+")"
        let attributedDescription = NSMutableAttributedString(string: event.shortDescription!)
        // TODO: why is setLineHeight and textContainerInset both required to make this fit correctly?
        attributedDescription.setLineHeight(18)
        attributedDescription.setFont(eventDescriptionLabel.font!)
        attributedDescription.setColor(UIColor.whiteColor())
        eventDescriptionLabel.attributedText = attributedDescription

        let sourceGesture = UITapGestureRecognizer(target: self, action: #selector(EventDetailCell.sourceTapped(_:)))
        eventSourceLabel.addGestureRecognizer(sourceGesture)
        let mapGesture = UITapGestureRecognizer(target: self, action: #selector(EventDetailCell.mapTapped(_:)))
        eventMapView.addGestureRecognizer(mapGesture)
        let venueGesture = UITapGestureRecognizer(target: self, action: #selector(EventDetailCell.mapTapped(_:)))
        eventVenueLabel.addGestureRecognizer(venueGesture)
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(EventDetailCell.imageTapped(_:)))
        eventCoverImageView.addGestureRecognizer(imageGesture)

        // setup map if possible
        if (event.geoloc != nil) {
            eventMapView.hidden = false
            let annotation:MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = event.geoloc!.coordinate
            eventMapView.addAnnotation(annotation)
            eventMapView.centerCoordinate = annotation.coordinate
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000,1000)
            eventMapView.setRegion(region, animated:false)
        } else {
            eventMapView.hidden = true
        }

        linkContent = FBSDKShareLinkContent()
        linkContent.contentURL = event.danceDeetsUrl
        linkContent.imageURL = NSURL(string: "http://www.dancedeets.com/events/image_proxy/" + event.id!)
        linkContent.contentTitle = event.title
        linkContent.contentDescription = event.description
        linkContent.placeID = event.venue?.id
        eventShareButton.shareContent = linkContent

        // set to initial image first, this may be a smaller image if coming from list view
        eventCoverImageView.image = initialImage
        if let url = event.eventImageUrl {
            // hero image for detail view is the big image
            let imageRequest:NSURLRequest = NSURLRequest(URL: url)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest) {
                eventCoverImageView.image = image
            } else {
                event.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if (image != nil && error == nil) {
                        self.eventCoverImageView.image = image
                    }
                })
            }

            // aspect ratio if available, capped at 1:1 to prevent super tall images
            if event.eventImageHeight != nil && event.eventImageWidth != nil {
                ASPECT_RATIO = min(1.0, event.eventImageHeight! / event.eventImageWidth!)
            }
            eventCoverImageViewHeightConstraint.constant = frame.size.width * ASPECT_RATIO
        } else {
            eventCoverImageViewHeightConstraint.constant = 0
        }

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
    
    func getEventUrl() -> NSURL? {
        var urlString = event.sourceUrl
        if event.isFbEvent() {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "fb://")!) {
                urlString = String(format: "fb://profile/%@", event.id!)
            }
        }
        if let url = urlString {
            return NSURL(string: url)!
        } else {
            CLSNSLogv("Error getting URL for event: %@", getVaList([event.id!]))
            return nil
        }
    }

    func sourceTapped(sender: AnyObject) {
        if (event != nil) {
            AnalyticsUtil.track("Open Source", withEvent: event)
            if let url = getEventUrl() {
                UIApplication.sharedApplication().openURL(url)
            } else {
                CLSNSLogv("%@", getVaList(["No source URL, not opening event source."]))
            }
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

    override func awakeFromNib() {
        super.awakeFromNib()

        // No idea why these are necessary, since they are set in the NIB
        sourceIconView.tintColor = UIColor.whiteColor()
        danceIconView.tintColor = UIColor.whiteColor()
        rsvpIconView.tintColor = UIColor.whiteColor()
        pinIconView.tintColor = UIColor.whiteColor()
        // No idea why we have to set this color directly, instead of copying another color
        // Seems there's some of magic going on with tintColor in multiple ways
        clockIconView.tintColor = UIColor(red: 192.0/255, green: 1.0, blue: 192.0/255, alpha: 1.0)
    }
}
