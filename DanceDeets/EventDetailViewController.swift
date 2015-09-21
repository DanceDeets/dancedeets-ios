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
    var backgroundOverlay:UIView!
    var loaded:Bool = false
    var initialImage:UIImage?
    
    var coverCell:UITableViewCell?{
        return tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
    }
    var timeCell:UITableViewCell?{
        return tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
    }
    var venueCell:UITableViewCell?{
        return tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
    }
    var descriptionCell:UITableViewCell?{
        return tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))
    }
    var mapCell:UITableViewCell?{
        return tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 5, inSection: 0))
    }
    
    @IBOutlet weak var eventCoverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UITextView!
    @IBOutlet weak var eventMapView: MKMapView!
    @IBOutlet weak var eventActionCell: EventDetailActionCell!

    
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
        if(segue.identifier == "fullScreenImageSegue"){
            let destinationController = segue.destinationViewController as! FullScreenImageViewController
            if let image = eventCoverImageView.image{
                destinationController.image = image
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // styling
        title = event!.title!.uppercaseString
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        shareButton.tintColor = ColorFactory.white50()
        navigationItem.rightBarButtonItem = shareButton
        
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
        let attributedDescription = NSMutableAttributedString(string: event.shortDescription!)
        // TODO: why is setLineHeight and textContainerInset both required to make this fit correctly?
        attributedDescription.setLineHeight(18)
        attributedDescription.setFont(eventDescriptionLabel.font!)
        attributedDescription.setColor(eventDescriptionLabel.textColor!)
        eventDescriptionLabel.attributedText = attributedDescription

        let tapGesture = UITapGestureRecognizer(target: self, action: "getDirectionButtonTapped:")
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
        
        eventActionCell.updateViewForEvent(event)

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
        
        self.tableView.backgroundView = UIImageView(image:UIImage(named: "streamBackground"))
        backgroundOverlay = self.tableView.backgroundView!.addDarkBlurOverlay()
        backgroundOverlay.alpha = 1
    }
    
    @IBAction func getDirectionButtonTapped(sender: AnyObject) {
        MapManager.showOnMap(event!)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: Action
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if (event != nil){
            let activityViewController = UIActivityViewController(activityItems: event!.createSharingItems(), applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }

    func eventImageHeight() -> CGFloat{
        return view.frame.size.width * ASPECT_RATIO
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let width:CGFloat = tableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
        print(width)

        if(indexPath.row == 0){
            // gap, cover image sits here but isn't part of the tableview
            return getTopOffset() + eventImageHeight()
        }else if(indexPath.row == 1){
            // title
            let height = Utilities.heightRequiredForText(event!.title!,
                lineHeight: FontFactory.eventHeadlineLineHeight(),
                font: eventTitleLabel.font,
                width:width)
            return height + 25
        }else if(indexPath.row == 2){
            // time
            return 24
        }else if(indexPath.row == 3){
            // display address
            var displayAddressHeight:CGFloat = 0.0
            displayAddressHeight += Utilities.heightRequiredForText(event!.displayAddress, lineHeight: FontFactory.eventVenueLineHeight(), font: FontFactory.eventVenueFont(), width: width)
            return displayAddressHeight
        }else if(indexPath.row == 4){
            //description
            let height = Utilities.heightRequiredForText(event!.shortDescription!,
                lineHeight: FontFactory.eventDescriptionLineHeight(),
                font: FontFactory.eventDescriptionFont(),
                width:width)
            return height + 30
        }else if(indexPath.row == 5){
            // map
            return 300;
        }else if(indexPath.row == 6){
            // CTAs
            return 55;
        }else{
            return CGFloat.min
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            AppDelegate.sharedInstance().allowLandscape = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("fullScreenImageSegue", sender: self)
            })
        }else if(indexPath.row == 3){
            MapManager.showOnMap(event!)
        }
    }

    /*
    // MARK: UIScrollViewDelegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOff = scrollView.contentOffset.y
        
        if(yOff < 0){
            eventCoverImageViewHeightConstraint.constant = self.eventImageHeight() - yOff
            eventCoverImageViewTopConstraint.constant = getTopOffset()
        }else{
            eventCoverImageViewHeightConstraint.constant = self.eventImageHeight()
            eventCoverImageViewTopConstraint.constant = getTopOffset() - yOff
        }
    }*/
    
    
}
