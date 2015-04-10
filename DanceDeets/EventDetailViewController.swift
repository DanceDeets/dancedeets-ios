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

class EventDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate, UIAlertViewDelegate{
    
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 15.0
    var COVER_IMAGE_TOP_OFFSET:CGFloat = 0.0
    var COVER_IMAGE_HEIGHT:CGFloat = 0.0
    var COVER_IMAGE_LEFT_OFFSET:CGFloat = 0.0
    var COVER_IMAGE_RIGHT_OFFSET:CGFloat = 0.0
    
    var event:Event!
    var backgroundOverlay:UIView!
    var loaded:Bool = false
    var directionAlert:UIAlertView?
    var initialImage:UIImage?
    
    var coverCell:UITableViewCell?{
        return detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
    }
    var timeCell:UITableViewCell?{
        return detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
    }
    var venueCell:UITableViewCell?{
        return detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
    }
    var descriptionCell:UITableViewCell?{
        return detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))
    }
    var mapCell:UITableViewCell?{
        return detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 5, inSection: 0))
    }
    
    @IBOutlet weak var eventCoverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var detailsTableView: UITableView!
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
        
        title = event!.title!.uppercaseString
        var shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        shareButton.tintColor = ColorFactory.white50()
        navigationItem.rightBarButtonItem = shareButton
        
        var backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonTapped")
        backButton.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0)
        backButton.tintColor = ColorFactory.white50()
        navigationItem.leftBarButtonItem = backButton

        var titleOptions = [NSObject:AnyObject]()
        titleOptions[NSForegroundColorAttributeName] = UIColor.whiteColor()
        titleOptions[NSFontAttributeName] = FontFactory.navigationTitleFont()
        navigationController?.navigationBar.titleTextAttributes = titleOptions
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        eventCoverImageViewTopConstraint.constant = COVER_IMAGE_TOP_OFFSET
        eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT
        eventCoverImageViewLeftConstraint.constant = COVER_IMAGE_LEFT_OFFSET
        eventCoverImageViewRightConstraint.constant = COVER_IMAGE_RIGHT_OFFSET
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        
        navigationController?.interactivePopGestureRecognizer.delegate = self
        navigationController?.interactivePopGestureRecognizer.enabled = true
        
        if let image = initialImage{
            eventCoverImageView.image = image
        }
        if let url = event.eventImageUrl{
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
        
        backgroundOverlay = backgroundView.addDarkBlurOverlay()
        backgroundOverlay.alpha = 0
        directionAlert = UIAlertView(title: "Get some directions to the venue?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Walk", "Drive")
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // to support the fade in effect
        if(!loaded && indexPath.row >= 1 && indexPath.row <= 5){
            cell.alpha = 0
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // only do the fade in animation once
        if(!loaded){
            loaded = true
            view.layoutIfNeeded()
            backgroundOverlay?.fadeIn(0.6,completion:nil)
            
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.eventCoverImageViewLeftConstraint.constant = -25
                self.eventCoverImageViewRightConstraint.constant = -25
                self.eventCoverImageViewTopConstraint.constant = 40
                self.eventCoverImageViewHeightConstraint.constant =  self.COVER_IMAGE_HEIGHT + 50
                self.view.layoutIfNeeded()
                }) { (bool:Bool) -> Void in
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        self.eventCoverImageViewLeftConstraint.constant = 0
                        self.eventCoverImageViewRightConstraint.constant = 0
                        self.eventCoverImageViewTopConstraint.constant = self.getTopOffset()
                        self.eventCoverImageViewHeightConstraint.constant =  self.COVER_IMAGE_HEIGHT
                        self.view.layoutIfNeeded()
                        
                        }) { (bool:Bool) -> Void in
                            
                            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                                self.coverCell?.alpha = 1
                                return
                                }, completion: nil)
                            UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                                self.timeCell?.alpha = 1
                                return
                                }, completion: nil)
                            UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                                self.venueCell?.alpha = 1
                                return
                                }, completion: nil)
                            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                                self.descriptionCell?.alpha = 1
                                return
                                }, completion: nil)
                            UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                                self.mapCell?.alpha = 1
                                return
                                }, completion: nil)
                    }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Action
    func imageViewTapped(){
        AppDelegate.sharedInstance().allowLandscape = true
        performSegueWithIdentifier("fullScreenImageSegue", sender: self)
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if (event != nil){
            let activityViewController = UIActivityViewController(activityItems: event!.createSharingItems(), applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("gapCell", forIndexPath: indexPath) as! UITableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCoverCell", forIndexPath: indexPath) as! EventDetailCoverCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 2){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventTimeCell", forIndexPath: indexPath) as! EventDetailTimeCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 3){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventLocationCell", forIndexPath: indexPath) as! EventDetailLocationCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 4){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventDescriptionCell", forIndexPath: indexPath) as! EventDetailDescriptionCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 5){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventMapCell", forIndexPath: indexPath) as! EventDetailMapCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 6){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventActionCell", forIndexPath: indexPath) as! EventDetailActionCell
            cell.updateViewForEvent(event!)
            return cell
        }else{
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "default")
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)

        if(indexPath.row == 0){
            // gap, cover image sits here but isn't part of the tableview
            return getTopOffset() + COVER_IMAGE_HEIGHT
        }else if(indexPath.row == 1){
            // title
            let height = Utilities.heightRequiredForText(event!.title!,
                lineHeight: FontFactory.eventHeadlineLineHeight(),
                font: FontFactory.eventHeadlineFont(),
                width:width)
            return height + 20
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
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            AppDelegate.sharedInstance().allowLandscape = true
            performSegueWithIdentifier("fullScreenImageSegue", sender: self)
        }else if(indexPath.row == 3 || indexPath.row == 5){
            if ( event.placemark != nil){
                directionAlert?.show()
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOff = scrollView.contentOffset.y
        
        if(yOff < 0){
            eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT - yOff
            eventCoverImageViewTopConstraint.constant = getTopOffset()
        }else{
            eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT
            eventCoverImageViewTopConstraint.constant = getTopOffset() - yOff
        }
    }
    
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if(alertView == directionAlert){
            if(buttonIndex == 1){
                let placemark = MKPlacemark(placemark: event.placemark!)
                let mapItem:MKMapItem = MKMapItem(placemark: placemark)
                
                let launchOptions:[NSObject : AnyObject] = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
            }else if(buttonIndex == 2){
                let placemark = MKPlacemark(placemark: event.placemark!)
                let mapItem:MKMapItem = MKMapItem(placemark: placemark)
                
                let launchOptions:[NSObject : AnyObject] = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
            }
            
        }
    }
    
}
