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

class EventDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    let DETAILS_TABLE_VIEW_TOP_MARGIN:CGFloat = 70.0
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 15.0
    var COVER_IMAGE_TOP_OFFSET:CGFloat = 0.0
    var COVER_IMAGE_HEIGHT:CGFloat = 0.0
    let EVENT_TIME_CELL_HEIGHT:CGFloat = 24
    
    var event:Event?
    var gradientLayer:CAGradientLayer?
    var redirectGradientLayer:CAGradientLayer?
    var backgroundOverlay:UIView?
    
    var detailTableBlur:UIView?
    let DETAIL_BLUR_DRAG_OFF:CGFloat = 100.0
    
    var coverCell:UITableViewCell?
    var timeCell:UITableViewCell?
    var venueCell:UITableViewCell?
    var descriptionCell:UITableViewCell?
    var mapCell:UITableViewCell?
    
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
        
        title = event!.title!.uppercaseString
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        navigationItem.rightBarButtonItem = shareButton
        
        let titleOptions:NSMutableDictionary = NSMutableDictionary()
        titleOptions[NSForegroundColorAttributeName] = UIColor.whiteColor()
        titleOptions[NSFontAttributeName] = FontFactory.navigationTitleFont()
        navigationController?.navigationBar.titleTextAttributes = titleOptions
        
        eventCoverImageViewTopConstraint.constant = COVER_IMAGE_TOP_OFFSET
        eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT
        
        backgroundOverlay = backgroundView.addDarkBlurOverlay()
        backgroundOverlay!.alpha = 0
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        detailsTableView.backgroundColor = UIColor.clearColor()
        
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
        
        detailsTableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let finalTopOff = navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        println(finalTopOff)
        
        coverCell = detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        coverCell?.alpha = 0
        timeCell = detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
        timeCell?.alpha = 0
        venueCell = detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))
        venueCell?.alpha = 0
        descriptionCell = detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 5, inSection: 0))
        descriptionCell?.alpha = 0
        mapCell = detailsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 6, inSection: 0))
        mapCell?.alpha = 0
        
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        backgroundOverlay?.fadeIn(0.6,nil)
       
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.eventCoverImageViewLeftConstraint.constant = -75
            self.eventCoverImageViewRightConstraint.constant = -75
            self.eventCoverImageViewTopConstraint.constant = 20
            
            self.eventCoverImageViewHeightConstraint.constant =  self.COVER_IMAGE_HEIGHT + 150
            self.view.layoutIfNeeded()
            
            }) { (bool:Bool) -> Void in
                
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                
                UIView.animateWithDuration(0.15, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.eventCoverImageViewLeftConstraint.constant = 0
                    self.eventCoverImageViewRightConstraint.constant = 0
                    self.eventCoverImageViewTopConstraint.constant = finalTopOff
                    self.eventCoverImageViewHeightConstraint.constant =  self.COVER_IMAGE_HEIGHT
                    self.view.layoutIfNeeded()
                    
                    }) { (bool:Bool) -> Void in
                        
                       
                        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            println("HERE")
                            self.coverCell?.alpha = 1
                        }, completion: nil)
                        UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            println("HERE")
                            self.timeCell?.alpha = 1
                        }, completion: nil)
                        UIView.animateWithDuration(0.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            println("HERE")
                            self.venueCell?.alpha = 1
                        }, completion: nil)
                        UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            println("HERE")
                            self.descriptionCell?.alpha = 1
                        }, completion: nil)
                        UIView.animateWithDuration(0.5, delay: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                            println("HERE")
                            self.mapCell?.alpha = 1
                        }, completion: nil)
                        
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
            let cell = tableView.dequeueReusableCellWithIdentifier("gapCell", forIndexPath: indexPath) as UITableViewCell
            cell.backgroundColor = UIColor.clearColor()
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
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)

        if(indexPath.row == 0){
            // under nav bar + status bar
            if(navigationController != nil){
            return navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
            }else{
                return CGFloat.min
            }
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
        
        if(yOff<0){
            eventCoverImageViewHeightConstraint.constant = (COVER_IMAGE_HEIGHT - (yOff))
        
            
        }else{
            eventCoverImageViewHeightConstraint.constant = COVER_IMAGE_HEIGHT
            eventCoverImageViewTopConstraint.constant = 64 - yOff
        }
        
        view.layoutIfNeeded()

    }
    
}
