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

class EventDetailCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 15.0

    var ASPECT_RATIO:CGFloat = 1.0
    
    var event:Event!
    var initialImage:UIImage?
    
    var addToCalendar:AddToCalendar?

    var tableView:UITableView?

    @IBOutlet weak var eventCoverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var eventCategoriesLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UITextView!
    @IBOutlet weak var eventMapView: MKMapView!

    
    @IBOutlet var bottomToolbarItems: UIToolbar!
    
    @IBOutlet weak var eventCoverImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCoverImageViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCoverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCoverImageViewLeftConstraint: NSLayoutConstraint!

    // MARK: UIViewController
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "fullScreenImageSegue") {
            let destinationController = segue.destinationViewController as! FullScreenImageViewController
            if let image = eventCoverImageView.image {
                destinationController.image = image
            }
            destinationController.event = event
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier",
            forIndexPath: indexPath)
        // We set backgroundColor = clearColor in Interface Builder, but iPads seem to require we set this in code
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: FIXME
        return 0
    }

    func viewDidLoad() {

        CLSLogv("EventDetailCell.viewDidLoad event id: \(event.id ?? "Unknown")", getVaList([]))
        AnalyticsUtil.track("View Event", withEvent: event)

        // styling
        parentViewController()!.title = event!.title!.uppercaseString
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        parentViewController()!.navigationItem.rightBarButtonItem = shareButton
        // TODO: what do we want to stick in the upper right?

        var titleOptions = [String:AnyObject]()
        titleOptions[NSFontAttributeName] = FontFactory.navigationTitleFont()
        parentViewController()!.navigationController?.navigationBar.titleTextAttributes = titleOptions

        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 10

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

        let tapGesture = UITapGestureRecognizer(target: self, action: "mapTapped:")
        eventMapView.addGestureRecognizer(tapGesture)

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
        if let url = event.eventImageUrl{
            // hero image for detail view is the big image
            let imageRequest:NSURLRequest = NSURLRequest(URL: url)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                eventCoverImageView.image = image
            } else {
                event?.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if(image != nil && error == nil){
                        self.eventCoverImageView.image = image
                    }
                })
            }
        }
        

        // aspect ratio if available, capped at 1:1 to prevent super tall images
        if event.eventImageHeight != nil && event.eventImageWidth != nil{
            ASPECT_RATIO = min(1.0, event.eventImageHeight! / event.eventImageWidth!)
        }
        
        eventCoverImageView.userInteractionEnabled = false
    }

    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    // MARK: Buttons
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if (event != nil) {
            AnalyticsUtil.track("Share Event", withEvent: event)
            let activityViewController = UIActivityViewController(activityItems: event!.createSharingItems(), applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            self.parentViewController()!.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func mapTapped(sender: AnyObject?) {
        AnalyticsUtil.track("View on Map", withEvent: event)
        MapManager.showOnMap(event!)
    }
    
    @IBAction func facebookTapped(sender: AnyObject) {
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
    
    @IBAction func calendarTapped(sender: AnyObject) {
        AnalyticsUtil.track("Add to Calendar", withEvent: event)
        addToCalendar = AddToCalendar(event: event)
        addToCalendar!.addToCalendar()
    }
    
    @IBAction func rsvpTapped(sender: AnyObject) {
        let rsvp = FacebookRsvpManager.RSVP.Attending
        AnalyticsUtil.track("RSVP", withEvent: event, ["RSVP Value": rsvp.rawValue])
        FacebookRsvpManager.rsvpFacebook( event, withRsvp: rsvp)
    }
    
    func eventImageHeight() -> CGFloat{
        return frame.size.width * ASPECT_RATIO
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let width:CGFloat = frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
        var height = UITableViewAutomaticDimension
        var sizingView: UIView?
        if (indexPath.row == 1) {
            sizingView = eventTitleLabel
        } else if (indexPath.row == 2) {
            sizingView = eventCategoriesLabel
        } else if (indexPath.row == 3) {
            sizingView = eventTimeLabel
        } else if (indexPath.row == 4) {
            sizingView = eventVenueLabel
        } else if (indexPath.row == 5) {
            sizingView = eventDescriptionLabel
        }
        if sizingView != nil {
            let padding: CGFloat = 8.0
            height = padding + sizingView!.sizeThatFits(CGSize(width: width, height: CGFloat(FLT_MAX))).height
        }
        return height
    }

    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            AppDelegate.sharedInstance().allowLandscape = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.parentViewController()!.performSegueWithIdentifier("fullScreenImageSegue", sender: self)
            })
        } else if(indexPath.row == 4) {
            mapTapped(nil)
        }
    }
    
}
