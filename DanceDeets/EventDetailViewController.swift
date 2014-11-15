//
//  EventDetailViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import EventKit

class EventDetailViewController: UIViewController,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource {

    let DETAILS_TABLE_VIEW_TOP_MARGIN:CGFloat = 70.0
    let DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING:CGFloat = 20.0
    let DETAILS_TABLE_VIEW_CELL_VERTICAL_PADDING:CGFloat = 10.0
    var BLUR_THRESHOLD_OFFSET:CGFloat = 0.0
    let BLUR_MAX_ALPHA:CGFloat = 0.75
    let PARALLAX_SCROLL_OFFSET:CGFloat = 80.0
    var event:Event?
    var overlayView:UIVisualEffectView?
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var backgroundViewTopConstraint: NSLayoutConstraint!
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        detailsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        BLUR_THRESHOLD_OFFSET = view.frame.size.height
        
        // to enable default pop gesture recognizer, it turns off by 
        // default when you hide the nav bar
        navigationController?.interactivePopGestureRecognizer.enabled = true
        navigationController?.interactivePopGestureRecognizer.delegate = self
        
        // TODO Use cached image from previous controller
        let request: NSURLRequest = NSURLRequest(URL: event!.eventImageUrl!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                let newImage = UIImage(data: data)
                dispatch_async(dispatch_get_main_queue(), {
                    self.coverImageView.image = newImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        
        overlayView = UIVisualEffectView(effect: UIBlurEffect(style:UIBlurEffectStyle.Dark)) as UIVisualEffectView
        coverImageView.addSubview(overlayView!)
        overlayView?.constrainToSuperViewBounds()
        overlayView?.alpha = 0
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    @IBAction func mapButtonTapped(sender: AnyObject) {
        println("mapped button tapped")
    }
    
    @IBAction func calendarButtonTapped(sender: AnyObject) {
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
                // default 2 hours
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
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        // Simple iOS action sheet
        var sharingItems:[AnyObject] = []
        
        if let title = event?.title{
            sharingItems.append("Check out this event: " + title)
        }
        
        if let url = event?.facebookUrl{
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("eventCoverCell", forIndexPath: indexPath) as EventDetailCoverCell
            cell.updateViewForEvent(event!)
            return cell
        }else if(indexPath.row == 1){
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
        return 2
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return view.frame.size.height - DETAILS_TABLE_VIEW_TOP_MARGIN
        }else if(indexPath.row == 1){
            
            let width:CGFloat = detailsTableView.frame.size.width - (2*DETAILS_TABLE_VIEW_CELL_HORIZONTAL_PADDING)
            
            let height = Utilities.heightRequiredForText(event!.shortDescription!,
                lineHeight: EventDetailDescriptionCell.descriptionLineHeight(),
                font: EventDetailDescriptionCell.descriptionFont(),
                width:width)
            return height + (2*DETAILS_TABLE_VIEW_CELL_VERTICAL_PADDING)
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
        //  println(scrollView.contentOffset.y)
        // Update blur by scroll
        let currentVertOffset = scrollView.contentOffset.y
        var boundedOffset:CGFloat = currentVertOffset
        
        if(currentVertOffset < 0){
            boundedOffset = 0
        }else if(currentVertOffset > BLUR_THRESHOLD_OFFSET){
            boundedOffset = BLUR_THRESHOLD_OFFSET
        }
        
        backgroundViewTopConstraint.constant = -(boundedOffset/BLUR_THRESHOLD_OFFSET) * PARALLAX_SCROLL_OFFSET;
        println(backgroundViewTopConstraint.constant)
        view.layoutIfNeeded()
        
        println(backgroundViewTopConstraint.constant)
        
        overlayView?.alpha = min(BLUR_MAX_ALPHA,boundedOffset/BLUR_THRESHOLD_OFFSET)
   
    }

}
