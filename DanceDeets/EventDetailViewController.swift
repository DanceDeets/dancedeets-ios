//
//  EventDetailViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import EventKit
import QuartzCore
import MapKit

class EventDetailViewController: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate {

    let DETAILS_TABLE_VIEW_TOP_MARGIN:CGFloat = 70.0
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 15.0
    let DETAILS_TABLE_VIEW_CELL_VERTICAL_PADDING:CGFloat = 20.0
    var COVER_IMAGE_TOP_OFFSET:CGFloat = 0.0
    var COVER_IMAGE_HEIGHT:CGFloat = 0.0
    let EVENT_TITLE_CELL_HEIGHT:CGFloat = 99.0
    let EVENT_TIME_CELL_HEIGHT:CGFloat = 30.5
    var SCROLL_LIMIT:CGFloat = 0.0
    
    var event:Event?
    var addCalendarAlert:UIAlertView?
    var facebookAlert:UIAlertView?
    var gradientLayer:CAGradientLayer?
    var redirectGradientLayer:CAGradientLayer?
    var backgroundOverlay:UIView?
    
    @IBOutlet weak var redirectView: RedirectView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventCoverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var backgroundViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCoverImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCoverImageViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var eventCoverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCoverImageViewLeftConstraint: NSLayoutConstraint!
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redirectView.redirectedView = detailsTableView
        mapView.userInteractionEnabled = false
        
        eventTitleLabel.textColor = UIColor.whiteColor()
        eventTitleLabel.font = FontFactory.navigationTitleFont()
        eventTitleLabel.text = event!.title!.uppercaseString
        eventCoverImageViewTopConstraint.constant = COVER_IMAGE_TOP_OFFSET
        eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT
        
        backgroundOverlay = coverImageView.addDarkBlurOverlay()
        backgroundOverlay?.alpha = 0
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        detailsTableView.backgroundColor = UIColor.clearColor() 
        
        // to enable default pop gesture recognizer
        // it seems to turns off when you hide the nav bar
        navigationController?.interactivePopGestureRecognizer.enabled = true
        navigationController?.interactivePopGestureRecognizer.delegate = self
        
        // background image
        if (event!.eventImageUrl != nil){
            let imageRequest:NSURLRequest = NSURLRequest(URL: event!.eventImageUrl!)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                eventCoverImageView.image = image
            }else{
                event?.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if(image != nil && error == nil){
                        self.eventCoverImageView.image = image
                    }
                })
            }
        }else{
            eventCoverImageView.image = UIImage(named: "placeholderCover")
        }
        
        addCalendarAlert = UIAlertView(title: "Want to add this event to your calendar?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        facebookAlert = UIAlertView(title: "RSVP on Facebook?", message: "", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        
        // this sets up a gradient mask on the table view layer, which gives the fade out effect
        // when you scroll 
        gradientLayer = CAGradientLayer()
        let outerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor
        let innerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(1.0).CGColor
        gradientLayer?.colors = [outerColor,innerColor,innerColor]
        gradientLayer?.locations = [NSNumber(float: 0.0), NSNumber(float:0.01), NSNumber(float: 1.0)]
        gradientLayer?.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        gradientLayer?.anchorPoint = CGPoint.zeroPoint
        self.detailsTableView.layer.mask = gradientLayer
        
        redirectGradientLayer = CAGradientLayer()
        redirectGradientLayer?.colors = [outerColor,innerColor,innerColor]
        redirectGradientLayer?.locations = [NSNumber(float: 0.0), NSNumber(float:0.01), NSNumber(float: 1.0)]
        redirectGradientLayer?.bounds = view.bounds
        redirectGradientLayer?.anchorPoint = CGPoint.zeroPoint
        redirectGradientLayer?.position = CGPointMake(0, -10)
        redirectView.layer.mask = redirectGradientLayer
        
        self.view.layoutIfNeeded()
        
        let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
        var displayAddressHeight:CGFloat = 0.0
        displayAddressHeight += Utilities.heightRequiredForText(event!.displayAddress!, lineHeight: FontFactory.eventVenueLineHeight(), font: FontFactory.eventVenueFont(), width: width)
        SCROLL_LIMIT = EVENT_TIME_CELL_HEIGHT + displayAddressHeight + 40
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        backgroundOverlay?.fadeIn(0.6,nil)
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.eventCoverImageViewLeftConstraint.constant = 0
            self.eventCoverImageViewRightConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Action
    @IBAction func backButtonTapped(sender: AnyObject) {
        
        backgroundOverlay?.fadeOut(0.6, completion: { () -> Void in
            println("backButtonTapped()")
            self.navigationController?.popViewControllerAnimated(false)
        })
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.eventCoverImageViewLeftConstraint.constant = self.DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING
            self.eventCoverImageViewRightConstraint.constant = self.DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func calendarButtonTapped(sender: AnyObject) {
        addCalendarAlert?.show()
    }
    @IBAction func facebookButtonTapped(sender: AnyObject) {
        facebookAlert?.show()
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if (event != nil){
            let activityViewController = UIActivityViewController(activityItems: event!.createSharingItems(), applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: UIAlertViewDelegate
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        if(alertView == addCalendarAlert)
        {
            if (buttonIndex == 1){
                var store = EKEventStore()
                store.requestAccessToEntityType(EKEntityTypeEvent) { (granted:Bool, error:NSError!) -> Void in
                    
                    if(!granted && error != nil){
                        return
                    }
                    
                    var newEvent:EKEvent = EKEvent(eventStore: store)
                    newEvent.title = self.event?.title
                    newEvent.startDate = self.event?.startTime
                    if let endTime = self.event?.endTime{
                        newEvent.endDate = endTime
                    }else{
                        // no end time parsed out, default 2 hours
                        newEvent.endDate = newEvent.startDate.dateByAddingTimeInterval(2*60*60)
                    }
                    newEvent.calendar = store.defaultCalendarForNewEvents
                    var saveError:NSError?
                    store.saveEvent(newEvent, span: EKSpanThisEvent, commit: true, error: &saveError)
                    self.event?.savedEventId = newEvent.eventIdentifier
                    
                    if(saveError == nil){
                        var message:String?
                        if let title = self.event?.title{
                            message = "Added " + title + " to your calendar!"
                        }else{
                            message = "Added to your calendar!"
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            let successAlert:UIAlertView = UIAlertView(title: "Dope", message: message, delegate: nil, cancelButtonTitle: "OK")
                            successAlert.show()
                        })
                    }
                }
            }
        }else if(alertView == facebookAlert){
            if(buttonIndex == 1){
                let graphPath = "/" + event!.identifier! + "/attending"
                FBRequestConnection.startWithGraphPath(graphPath, parameters: nil, HTTPMethod: "POST", completionHandler: { (conn:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                    if(error == nil){
                        let successAlert = UIAlertView(title: "RSVP'd on Facebook!", message: "",delegate:nil, cancelButtonTitle: "OK")
                        successAlert.show()
                    }else{
                        let errorAlert = UIAlertView(title: "Couldn't RSVP right now, try again later.", message: "",delegate:nil, cancelButtonTitle: "OK")
                        errorAlert.show()
                    }
                })
            }
        }
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCoverCell", forIndexPath: indexPath) as EventDetailCoverCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventTimeCell", forIndexPath: indexPath) as EventDetailTimeCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 2){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventLocationCell", forIndexPath: indexPath) as EventDetailLocationCell
            cell.updateViewForEvent(event!)
            return cell
        }
        else if(indexPath.row == 3){
            let cell = tableView.dequeueReusableCellWithIdentifier("gapCell", forIndexPath: indexPath) as UITableViewCell
            return cell
        }
        else if(indexPath.row == 4){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventTimeCell", forIndexPath: indexPath) as EventDetailTimeCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 5){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventLocationCell", forIndexPath: indexPath) as EventDetailLocationCell
             cell.updateViewForEvent(event!)
             return cell
        }else if(indexPath.row == 6){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventDescriptionCell", forIndexPath: indexPath) as EventDetailDescriptionCell
            cell.updateViewForEvent(event!)
            return cell
        }
        else{
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
        var displayAddressHeight:CGFloat = 0.0
        displayAddressHeight += Utilities.heightRequiredForText(event!.displayAddress!, lineHeight: FontFactory.eventVenueLineHeight(), font: FontFactory.eventVenueFont(), width: width)
        
        if(indexPath.row == 0){
            return 99;
        }else if(indexPath.row == 1){
            return EVENT_TIME_CELL_HEIGHT
        }else if (indexPath.row == 2){
            return displayAddressHeight;
        }else if(indexPath.row == 3){
            return COVER_IMAGE_HEIGHT - EVENT_TIME_CELL_HEIGHT - displayAddressHeight;
        }else if(indexPath.row == 4){
            return EVENT_TIME_CELL_HEIGHT
        }else if(indexPath.row == 5){
            return displayAddressHeight;
        }else if(indexPath.row == 6){
            let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
            
            let height = Utilities.heightRequiredForText(event!.shortDescription!,
                lineHeight: FontFactory.eventDescriptionLineHeight(),
                font: FontFactory.eventDescriptionFont(),
                width:width)
            return height + 70
            
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
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
       
        let yOff = scrollView.contentOffset.y
        println(yOff)
        
        if(yOff > SCROLL_LIMIT){
            let diff = yOff - SCROLL_LIMIT
            eventCoverImageViewTopConstraint.constant = COVER_IMAGE_TOP_OFFSET - diff
            view.layoutIfNeeded()
        }else if(yOff < 0){
            eventCoverImageViewTopConstraint.constant = COVER_IMAGE_TOP_OFFSET - yOff
            view.layoutIfNeeded()
        }
        
        var redirectGradientPosition:CGPoint?
        if(eventCoverImageViewTopConstraint.constant < DETAILS_TABLE_VIEW_TOP_MARGIN){
            var diff =  (DETAILS_TABLE_VIEW_TOP_MARGIN - eventCoverImageViewTopConstraint.constant)
            redirectGradientPosition = CGPointMake(0, diff)
        }else{
            redirectGradientPosition = CGPointMake(0, -10)
        }
        println(redirectGradientPosition)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer?.position = CGPointMake(0, scrollView.contentOffset.y)
        redirectGradientLayer?.position = redirectGradientPosition!
        CATransaction.commit()
        
        // handle map to image dissolve
        if(yOff < 0){
            // only show image
            eventCoverImageView.alpha = 1
            mapView.alpha = 0
            
        }else if(yOff >= 0 && yOff < SCROLL_LIMIT){
            let percentageShow:CGFloat = yOff / SCROLL_LIMIT
            mapView.alpha = percentageShow
            eventCoverImageView.alpha = 1 - mapView.alpha
        }else{
            eventCoverImageView.alpha = 0
            mapView.alpha = 1
        }
    }
    
}
