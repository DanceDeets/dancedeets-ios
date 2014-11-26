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

class EventDetailViewController: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate {

    let DETAILS_TABLE_VIEW_TOP_MARGIN:CGFloat = 64.0
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 20.0
    let DETAILS_TABLE_VIEW_CELL_VERTICAL_PADDING:CGFloat = 10.0
    var BLUR_THRESHOLD_OFFSET:CGFloat = 0.0
    let BLUR_MAX_ALPHA:CGFloat = 0.65
    let PARALLAX_SCROLL_OFFSET:CGFloat = 80.0
    
    var event:Event?
    var overlayView:UIVisualEffectView?
    var addCalendarAlert:UIAlertView?
    var facebookAlert:UIAlertView?
    var gradientLayer:CAGradientLayer?
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var backgroundViewTopConstraint: NSLayoutConstraint!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        BLUR_THRESHOLD_OFFSET = (view.frame.size.height * 4)/5
        
        // to enable default pop gesture recognizer
        // it seems to turns off when you hide the nav bar
        navigationController?.interactivePopGestureRecognizer.enabled = true
        navigationController?.interactivePopGestureRecognizer.delegate = self
        
        // background image
        if (event!.eventImageUrl != nil){
            let imageRequest:NSURLRequest = NSURLRequest(URL: event!.eventImageUrl!)
            if let image = ImageCache.sharedInstance.cachedImageForRequest(imageRequest){
                coverImageView.image = image
            }else{
                event?.downloadCoverImage({ (image:UIImage!, error:NSError!) -> Void in
                    if(image != nil && error == nil){
                        self.coverImageView.image = image
                    }
                })
            }
        }
        
        addCalendarAlert = UIAlertView(title: "Want to add this event to your calendar?", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        facebookAlert = UIAlertView(title: "RSVP on Facebook?", message: "", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        
        // the blur effect view over the entire cover image
        overlayView = UIVisualEffectView(effect: UIBlurEffect(style:UIBlurEffectStyle.Dark)) as UIVisualEffectView
        coverImageView.addSubview(overlayView!)
        overlayView?.constrainToSuperViewEdges()
        overlayView?.alpha = 0
        
        // this sets up a gradient mask on the table view layer, which gives the fade out effect
        // when you scroll 
        gradientLayer = CAGradientLayer()
        let outerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor
        let innerColor:CGColorRef = UIColor.blackColor().colorWithAlphaComponent(1.0).CGColor
        gradientLayer?.colors = [outerColor,innerColor,innerColor]
        gradientLayer?.locations = [NSNumber(float: 0.0), NSNumber(float:0.1), NSNumber(float: 1.0)]
        gradientLayer?.bounds = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - DETAILS_TABLE_VIEW_TOP_MARGIN)
        gradientLayer?.anchorPoint = CGPoint.zeroPoint
        self.detailsTableView.layer.mask = gradientLayer
        
        self.view.layoutIfNeeded()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
      //  let snap:UIView = coverImageView.snapshotViewAfterScreenUpdates(true)
       // coverImageView.removeFromSuperview()
       //
     //   backgroundView.addSubview(snap)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Action
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
            let cell = tableView.dequeueReusableCellWithIdentifier("eventDescriptionCell", forIndexPath: indexPath) as EventDetailDescriptionCell
            cell.updateViewForEvent(event!)
            return cell
        }
        else if(indexPath.row == 3){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventLocationCell", forIndexPath: indexPath) as EventDetailLocationCell
            cell.updateViewForEvent(event!)
            return cell
        }
        else{
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "default")
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return view.frame.size.height - DETAILS_TABLE_VIEW_TOP_MARGIN
        }else if(indexPath.row == 1){
            return 40.0;
        }else if(indexPath.row == 2){
            let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
            
            let height = Utilities.heightRequiredForText(event!.shortDescription!,
                lineHeight: EventDetailDescriptionCell.descriptionLineHeight(),
                font: EventDetailDescriptionCell.descriptionFont(),
                width:width)
            return height + (2*DETAILS_TABLE_VIEW_CELL_VERTICAL_PADDING)
            
        }else if(indexPath.row == 3){
            let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
            var height:CGFloat = 0.0
            
            height += 2 * DETAILS_TABLE_VIEW_CELL_VERTICAL_PADDING
            
            height += Utilities.heightRequiredForText(event!.venue!, lineHeight: EventDetailLocationCell.venueLineHeight(), font: EventDetailLocationCell.venueFont(), width: width)
            
            if(event?.placemark != nil){
                // to fit the full adress + map if there is a placemark
                height += 210
            }
            return height
        }
        else{
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
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer?.position = CGPointMake(0, scrollView.contentOffset.y);
        CATransaction.commit()
        
        // blurs and slight parallax when scrolling down
        let currentVertOffset = scrollView.contentOffset.y
        var boundedOffset:CGFloat = currentVertOffset
        
        if(currentVertOffset < 0){
            boundedOffset = 0
        }else if(currentVertOffset > BLUR_THRESHOLD_OFFSET){
            boundedOffset = BLUR_THRESHOLD_OFFSET
        }
        
        backgroundViewTopConstraint.constant = -(boundedOffset/BLUR_THRESHOLD_OFFSET) * PARALLAX_SCROLL_OFFSET;
        view.layoutIfNeeded()
        
        overlayView?.alpha = min(BLUR_MAX_ALPHA,boundedOffset/BLUR_THRESHOLD_OFFSET)
    }

}
