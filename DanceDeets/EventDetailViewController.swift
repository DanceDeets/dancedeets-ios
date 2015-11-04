//
//  EventDetailViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit

class EventDetailViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 15.0

    var ASPECT_RATIO:CGFloat = 1.0
    
    var event:Event!
    var initialImage:UIImage?
    
    var addToCalendar:AddToCalendar?
    
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

    func getTopOffset()->CGFloat{
        if(navigationController != nil){
            return navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        }else{
            return CGFloat.min
        }
    }
    
    func backButtonTapped(){
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "fullScreenImageSegue") {
            let destinationController = segue.destinationViewController as! FullScreenImageViewController
            if let image = eventCoverImageView.image {
                destinationController.image = image
            }
            destinationController.event = event
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath:indexPath)
        // We set backgroundColor = clearColor in Interface Builder, but iPads seem to require we set this in code
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        CLSLogv("EventDetailViewController.viewDidLoad event id: \(event.id ?? "Unknown")", getVaList([]))
        AnalyticsUtil.track("View Event", withEvent: event)

        // Use the toolbars from the toolbar we set up in Interface Builder
        self.toolbarItems = bottomToolbarItems.items

        // styling
        title = event!.title!.uppercaseString
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        shareButton.tintColor = ColorFactory.white50()
        navigationItem.rightBarButtonItem = shareButton
        // TODO: what do we want to stick in the upper right?
        
        let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonTapped")
        backButton.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0)
        backButton.tintColor = ColorFactory.white50()
        navigationItem.leftBarButtonItem = backButton

        var titleOptions = [String:AnyObject]()
        titleOptions[NSForegroundColorAttributeName] = UIColor.whiteColor()
        titleOptions[NSFontAttributeName] = FontFactory.navigationTitleFont()
        navigationController?.navigationBar.titleTextAttributes = titleOptions
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
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
        
        navigationController?.interactivePopGestureRecognizer!.delegate = self
        navigationController?.interactivePopGestureRecognizer!.enabled = true
        
        // set to initial image first, this may be a smaller image if coming from list view
        eventCoverImageView.image = initialImage
        if let url = event.eventImageUrl{
            // hero image for detail view is the big image
            let imageRequest:NSURLRequest = NSURLRequest(URL: url)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                eventCoverImageView.image = image
            }else{
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
        
        self.tableView.backgroundColor = UIColor(white: 0, alpha: 1)
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: false)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    // MARK: Buttons
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if (event != nil) {
            AnalyticsUtil.track("Share Event", withEvent: event)
            let activityViewController = UIActivityViewController(activityItems: event!.createSharingItems(), applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
            self.presentViewController(activityViewController, animated: true, completion: nil)
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
        return view.frame.size.width * ASPECT_RATIO
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let width:CGFloat = tableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)

        var height:CGFloat?
        if (indexPath.row == 0) {
            // gap, cover image sits here but isn't part of the tableview
            height = getTopOffset() + eventImageHeight()
        } else if(indexPath.row == 1) {
            // title
            let textHeight = Utilities.heightRequiredForText(eventTitleLabel.text!,
                lineHeight: FontFactory.eventHeadlineLineHeight(),
                font: eventTitleLabel.font,
                width:width)
            height = textHeight + 25
        } else if(indexPath.row == 2) {
            // categories
            let textHeight = Utilities.heightRequiredForText(eventCategoriesLabel.text!,
                lineHeight: FontFactory.eventDescriptionLineHeight(),
                font: eventCategoriesLabel.font!,
                width:width)
            height = textHeight
        } else if(indexPath.row == 3) {
            // time
            height = 24
        } else if(indexPath.row == 4) {
            // display address
            var displayAddressHeight:CGFloat = 0.0
            displayAddressHeight += Utilities.heightRequiredForText(eventVenueLabel.text!,
                lineHeight: FontFactory.eventVenueLineHeight(),
                font: eventVenueLabel.font,
                width: width)
            height = displayAddressHeight
        } else if(indexPath.row == 5) {
            //description
            let textHeight = Utilities.heightRequiredForText(eventDescriptionLabel.text,
                lineHeight: FontFactory.eventDescriptionLineHeight(),
                font: eventDescriptionLabel.font!,
                width:width)
            height = textHeight + 30
        } else if(indexPath.row == 6) {
            // map
            height = 300;
        } else if(indexPath.row == 7) {
            // CTAs
            height = 55;
        } else {
            height = CGFloat.min
        }
        // print("Row \(indexPath.row) has height \(height)")
        return height!
    }

    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            AppDelegate.sharedInstance().allowLandscape = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("fullScreenImageSegue", sender: self)
            })
        }else if(indexPath.row == 4){
            mapTapped(nil)
        }
    }
    
}
