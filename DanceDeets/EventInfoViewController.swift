//
//  EventInfoViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 10/28/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import QuartzCore
import MapKit

class EventInfoViewController: UICollectionViewController, UIGestureRecognizerDelegate {

    var events:[Event]!
    var startEvent: Event?

    var adBar:AdBar?

    @IBOutlet var bottomToolbarItems: UIToolbar!

    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("eventCollectionViewCell", forIndexPath: indexPath) as! EventDetailCell
        cell.setupEvent(events[indexPath.row])

        // Ensure the cell contents don't have to underlap the navbar/toolbar
        let topHeightOffset = navigationController!.navigationBar.frame.size.height + navigationController!.navigationBar.frame.origin.y
        let bottomHeightOffset = navigationController!.toolbar.frame.size.height
        cell.scrollView.contentInset = UIEdgeInsetsMake(topHeightOffset, 0.0, bottomHeightOffset, 0.0)
        cell.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(topHeightOffset, 0.0, bottomHeightOffset, 0.0)
        cell.scrollView.setContentOffset(CGPoint(x:0, y:-topHeightOffset), animated: false)

        adBar?.maybeShowInterstitialAd()

        return cell
    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let event = currentEventCell()?.event {
            setCurrentEvent(event)
        }
    }

    func setCurrentEvent(event: Event) {
        AnalyticsUtil.track("View Event", withEvent: event)
        title = event.title!.uppercaseString
    }

    func currentEventCell() -> EventDetailCell? {
        if let cells = collectionView?.visibleCells() {
            // There may be multiple visibleCells (during scrolls), so we have to ensure we find the visible one
            for cell in cells {
                let cellRect = collectionView!.convertRect(cell.frame, toView:collectionView!.superview)
                if CGRectContainsRect(collectionView!.frame, cellRect) {
                    return cell as? EventDetailCell
                }
            }
        }
        return nil
    }

    // MARK: UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "fullScreenImageSegue") {
            if let cell = currentEventCell() {
                let destinationController = segue.destinationViewController as! FullScreenImageViewController
                if let image = cell.eventCoverImageView.image {
                    destinationController.image = image
                }
                destinationController.event = cell.event
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the toolbars from the toolbar we set up in Interface Builder
        self.toolbarItems = bottomToolbarItems.items
        navigationController?.toolbar.barTintColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8)

        // collection view
        let flowLayout:UICollectionViewFlowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsetsZero
        // Don't access view.frame directly: http://ashfurrow.com/blog/you-probably-dont-understand-frames-and-bounds/
        flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        // We don't want this done at the table level, but instead done within each cell,
        // up above in cellForItemAtIndexPath
        automaticallyAdjustsScrollViewInsets = false

        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonTapped:")
        navigationItem.rightBarButtonItem = shareButton

        var titleOptions = [String:AnyObject]()
        titleOptions[NSFontAttributeName] = FontFactory.navigationTitleFont()
        navigationController?.navigationBar.titleTextAttributes = titleOptions

        adBar = AdBar(controller: self)
    }

    override func viewDidLayoutSubviews() {
        // If we haven't done the initial scroll, do it once.
        if let event = startEvent {
            setCurrentEvent(event)
            if let index = events.indexOf(event) {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                collectionView!.layoutIfNeeded()
                collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition:UICollectionViewScrollPosition.CenteredHorizontally, animated:false)
            } else {
                CLSLogv("Event \(event.id) not in EventInfoViewController.events", getVaList([]))
            }
            startEvent = nil
        }
    }


    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)

        // It turns out to be really difficult to scroll the previous Stream VC down to the current VC's event
        // because many of the images are unloaded, and everything operates off estimated row heights.

        // Scroll the previous Stream viewcontroller down to the currently-viewed event. This code "mostly" works.
        if isBeingDismissed() || isMovingFromParentViewController() {
            if let streamController = parentViewController?.childViewControllers[0] as? EventStreamViewController {
                streamController.backToView()
            }
        }
    }

    @IBAction func facebookTapped(sender: AnyObject) {
        currentEventCell()?.facebookTapped(sender)
    }
    @IBAction func mapTapped(sender: AnyObject) {
        currentEventCell()?.mapTapped(sender)
    }
    @IBAction func calendarTapped(sender: AnyObject) {
        currentEventCell()?.calendarTapped(sender)
    }
    @IBAction func rsvpTapped(sender: AnyObject) {
        currentEventCell()?.rsvpTapped(sender)
    }
    @IBAction func shareButtonTapped(sender: AnyObject) {
        currentEventCell()?.shareButtonTapped(sender)
    }

}
