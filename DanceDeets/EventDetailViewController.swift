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

class EventDetailViewController: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate {

    let DETAILS_TABLE_VIEW_TOP_MARGIN:CGFloat = 70.0
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 15.0
    var COVER_IMAGE_TOP_OFFSET:CGFloat = 0.0
    var COVER_IMAGE_HEIGHT:CGFloat = 0.0
    let EVENT_TITLE_CELL_HEIGHT:CGFloat = 100.0
    let EVENT_TIME_CELL_HEIGHT:CGFloat = 30.5
    var SCROLL_LIMIT:CGFloat = 0.0
    
    var event:Event?
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
        
        
        title = event!.title!.uppercaseString
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        navigationItem.rightBarButtonItem = shareButton
        
        let titleOptions:NSMutableDictionary = NSMutableDictionary()
        titleOptions[NSForegroundColorAttributeName] = UIColor.whiteColor()
        titleOptions[NSFontAttributeName] = FontFactory.navigationTitleFont()
        navigationController?.navigationBar.titleTextAttributes = titleOptions
        
        
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
        
     
        
        /*
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
       // redirectView.layer.mask = redirectGradientLayer
*/
        
        self.view.layoutIfNeeded()
        
        let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
        var displayAddressHeight:CGFloat = 0.0
        displayAddressHeight += Utilities.heightRequiredForText(event!.displayAddress!, lineHeight: FontFactory.eventVenueLineHeight(), font: FontFactory.eventVenueFont(), width: width)
        SCROLL_LIMIT = EVENT_TIME_CELL_HEIGHT + displayAddressHeight + 15
        
        /*
        
        // setup map if possible
        if(event?.geoloc != nil){
            let annotation:MKPointAnnotation = MKPointAnnotation()
            annotation.setCoordinate(event!.geoloc!.coordinate)
             mapView.addAnnotation(annotation)
             mapView.centerCoordinate = annotation.coordinate
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1500,1500)
             mapView.setRegion(region,animated:false)
        }
*/
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        backgroundOverlay?.fadeIn(0.6,nil)
       
        UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.eventCoverImageViewLeftConstraint.constant = -100
            self.eventCoverImageViewRightConstraint.constant = -100
            self.eventCoverImageViewTopConstraint.constant = 20
            
            self.eventCoverImageViewHeightConstraint.constant =  self.COVER_IMAGE_HEIGHT + 175
            self.view.layoutIfNeeded()
            
            }) { (bool:Bool) -> Void in
                
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.eventCoverImageViewLeftConstraint.constant = 0
                    self.eventCoverImageViewRightConstraint.constant = 0
                    self.eventCoverImageViewTopConstraint.constant = 64
                    self.eventCoverImageViewHeightConstraint.constant =  self.COVER_IMAGE_HEIGHT
                    self.view.layoutIfNeeded()
                    
                    }) { (bool:Bool) -> Void in
                        
                        self.eventCoverImageView.hidden = true
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
    @IBAction func redirectViewTapped(sender: AnyObject) {
        if(event?.placemark != nil){
        }
    }
    
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
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        if (event != nil){
            let activityViewController = UIActivityViewController(activityItems: event!.createSharingItems(), applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("gapCell", forIndexPath: indexPath) as UITableViewCell
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        else if(indexPath.row == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventImageCell", forIndexPath: indexPath) as EventDetailImageCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 2){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCoverCell", forIndexPath: indexPath) as EventDetailCoverCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 3){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventTimeCell", forIndexPath: indexPath) as EventDetailTimeCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 4){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventLocationCell", forIndexPath: indexPath) as EventDetailLocationCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 5){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventDescriptionCell", forIndexPath: indexPath) as EventDetailDescriptionCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 6){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventMapCell", forIndexPath: indexPath) as EventDetailMapCell
            cell.updateViewForEvent(event!)
            return cell
            
        }else if(indexPath.row == 7){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventActionCell", forIndexPath: indexPath) as EventDetailActionCell
            cell.updateViewForEvent(event!)
            return cell
        }
        else{
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "default")
            return cell
        }
        
        
        /*
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
*/
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)

        
        /*
        if(indexPath.row == 0){
            return 100;
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
            return height + 50
            
        }else{
            return CGFloat.min
        }
*/
        if(indexPath.row == 0){
            // under nav bar + status bar
            return navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        }
        else if(indexPath.row == 1){
            // cover image
            return COVER_IMAGE_HEIGHT
        }else if(indexPath.row == 2){
            // title
            let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
            
            let height = Utilities.heightRequiredForText(event!.title!,
                lineHeight: FontFactory.eventHeadlineLineHeight(),
                font: FontFactory.eventHeadlineFont(),
                width:width)
            return height + 20
        }else if(indexPath.row == 3){
            // time
            return EVENT_TIME_CELL_HEIGHT
        }else if(indexPath.row == 4){
            // display address
            var displayAddressHeight:CGFloat = 0.0
            displayAddressHeight += Utilities.heightRequiredForText(event!.displayAddress!, lineHeight: FontFactory.eventVenueLineHeight(), font: FontFactory.eventVenueFont(), width: width)
            return displayAddressHeight
        }else if(indexPath.row == 5){
            //description
            let height = Utilities.heightRequiredForText(event!.shortDescription!,
                lineHeight: FontFactory.eventDescriptionLineHeight(),
                font: FontFactory.eventDescriptionFont(),
                width:width)
            return height + 20
        }else if(indexPath.row == 6){
            return 300;
        }else if(indexPath.row == 7){
            return 55;
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
       
        let yOff = scrollView.contentOffset.y
        println(yOff)
        
        /*
 
        if(yOff < 0){
            eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT - (yOff)
            eventCoverImageViewTopConstraint.constant = COVER_IMAGE_TOP_OFFSET + yOff
        }else{
        
        eventCoverImageViewTopConstraint.constant = COVER_IMAGE_TOP_OFFSET - yOff
            
            
            // println(COVER_IMAGE_TOP_OFFSET)
            // println(eventCoverImageViewTopConstraint.constant)
            if eventCoverImageViewTopConstraint.constant < DETAILS_TABLE_VIEW_TOP_MARGIN{
                eventCoverImageViewTopConstraint.constant = DETAILS_TABLE_VIEW_TOP_MARGIN
                
                println(yOff -  EVENT_TITLE_CELL_HEIGHT)
                eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT - (yOff -  EVENT_TITLE_CELL_HEIGHT)
             //   view.layoutIfNeeded()
            }
        }
      
        
        var redirectGradientPosition:CGPoint?
        redirectGradientPosition = CGPointMake(0,(DETAILS_TABLE_VIEW_TOP_MARGIN - eventCoverImageViewTopConstraint.constant))
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer?.position = CGPointMake(0, scrollView.contentOffset.y)
      //  redirectGradientLayer?.position = redirectGradientPosition!
        CATransaction.commit()
        
        // image / map cross fade with scroll
        if(yOff < 0){
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
*/
    }
    
}
